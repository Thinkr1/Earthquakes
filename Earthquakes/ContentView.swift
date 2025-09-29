//
//  ContentView.swift
//  Earthquakes
//
//  Created by Pierre-Louis ML on 17/12/2024.
//

import SwiftUI
import SceneKit
import CoreLocation
import WebKit
import AppKit

struct Earthquake: Identifiable, Equatable {
    let id: String
    let mag: Double
    let MMI: Double?
    let sig: Double?
    let loc: String
    let place: String
    let lat: Double?
    let lon: Double?
    let depth: Double
    let url: String
    let time: String
}

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
}

extension Array {
    func chunked(_ size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0+size, count)])
        }
    }
}

struct ClickableSceneView: NSViewRepresentable {
    let scene: SCNScene
    var onNodeClick: (String) -> Void

    class ClickableSCNView: SCNView {
        weak var coordinator: Coordinator?
        override var acceptsFirstResponder: Bool { true }
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            window?.makeFirstResponder(self)
        }
        override func mouseDown(with event: NSEvent) {
            guard let coordinator = coordinator else { return super.mouseDown(with: event) }
            let location = convert(event.locationInWindow, from: nil)
            coordinator.performHitTest(at: location, in: self)
            super.mouseDown(with: event)
        }
    }

    func makeNSView(context: Context) -> SCNView {
        let scnView = ClickableSCNView()
        scnView.translatesAutoresizingMaskIntoConstraints = false
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = .clear
        scnView.isPlaying = true
        scnView.delegate = context.coordinator
        scnView.coordinator = context.coordinator
        
        context.coordinator.view = scnView
        return scnView
    }

    func updateNSView(_ nsView: SCNView, context: Context) {
        nsView.scene = scene
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onNodeClick: onNodeClick)
    }

    class Coordinator: NSObject, SCNSceneRendererDelegate, NSGestureRecognizerDelegate {
        var onNodeClick: (String) -> Void
        weak var view: SCNView?

        init(onNodeClick: @escaping (String) -> Void) {
            self.onNodeClick = onNodeClick
        }

        @objc func handleClick(_ gesture: NSClickGestureRecognizer) {
            guard let view = view else { return }
            let location = gesture.location(in: view)
            print("ClickableSceneView: click at \(location)")
            let results = view.hitTest(location, options: [SCNHitTestOption.boundingBoxOnly: true])
            guard var node = results.first?.node else {
                print("ClickableSceneView: no node hit")
                return
            }
            while node.name == nil, let parent = node.parent {
                node = parent
            }
            guard let name = node.name else {
                print("ClickableSceneView: hit unnamed node")
                return
            }
            print("ClickableSceneView: hit node named \(name)")
            if let idPart = name.split(separator: "_").last {
                onNodeClick(String(idPart))
            }
        }

        func performHitTest(at location: NSPoint, in view: SCNView) {
            print("ClickableSceneView: mouseDown at \(location)")
            
            let options: [SCNHitTestOption: Any] = [
                SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue,
                SCNHitTestOption.ignoreChildNodes: false,
                SCNHitTestOption.boundingBoxOnly: true, // faster than triangle-lvl tests
                SCNHitTestOption.firstFoundOnly: true,
                SCNHitTestOption.categoryBitMask: 0x2 // only consider "pin" nodes
            ]
            
            let results = view.hitTest(location, options: options)
            
            guard let result = results.first else {
                print("ClickableSceneView: no node hit (mouseDown)")
                return
            }
            
            var node = result.node
            print("ClickableSceneView: initial hit node: \(node)")
            
            while node.name == nil, let parent = node.parent {
                node = parent
            }
            
            guard let name = node.name else {
                print("ClickableSceneView: hit unnamed node (mouseDown)")
                return
            }
            
            print("ClickableSceneView: hit node named \(name) (mouseDown)")
            
            let components = name.split(separator: "_")
            if let idPart = components.last {
                print("ClickableSceneView: extracted ID: \(idPart)")
                onNodeClick(String(idPart))
            } else {
                print("ClickableSceneView: could not extract ID from name: \(name)")
            }
        }
    }
}

struct ContentView: View {
    @Namespace private var namespace
    @State private var settingsPanel: NSPanel? = nil
    @State private var earthquakes: [Earthquake] = []
    @State private var historicEarthquakes: [Earthquake] = [
        Earthquake(id: "1", mag: 9.5, MMI: 12, sig: nil, loc: "Chile, Valdivia", place: "Chile", lat: -39.8138, lon: -73.2404, depth: 25, url: "", time: "May 22, 1960"),
        Earthquake(id: "2", mag: 9.2, MMI: 10, sig: nil, loc: "United States, Alaska", place: "Alaska", lat: 61.3706, lon: -152.4044, depth: 25, url: "", time: "March 27, 1964"),
        Earthquake(id: "3", mag: 9.0, MMI: 11, sig: nil, loc: "USSR, Kamchatka", place: "Kamchatka", lat: 53.1018, lon: 158.6431, depth: 21.6, url: "", time: "November 5, 1952"),
        Earthquake(id: "4", mag: 8.8, MMI: 9, sig: nil, loc: "Ecuador – Colombia", place: "Ecuador – Colombia", lat: -0.1754, lon: -78.4678, depth: 20, url: "", time: "January 31, 1906"),
        Earthquake(id: "5", mag: 8.7, MMI: 6, sig: nil, loc: "United States, Alaska", place: "Alaska", lat: 61.3706, lon: -152.4044, depth: 30.3, url: "", time: "February 4, 1965"),
        Earthquake(id: "6", mag: 8.7, MMI: 11, sig: nil, loc: "India, Assam – China, Tibet", place: "India – China – Tibet", lat: 27.6074, lon: 91.9784, depth: 15, url: "", time: "August 15, 1950"),
        Earthquake(id: "7", mag: 8.6, MMI: 8, sig: nil, loc: "United States, Alaska", place: "Alaska", lat: 61.3706, lon: -152.4044, depth: 25, url: "", time: "March 9, 1957"),
        Earthquake(id: "8", mag: 8.6, MMI: 6, sig: nil, loc: "United States, Aleutian Island", place: "Aleutian Island", lat: 52.6644, lon: -175.1164, depth: 15, url: "", time: "April 1, 1946"),
        Earthquake(id: "9", mag: 8.5, MMI: 9, sig: nil, loc: "USSR, Kuril Islands", place: "USSR", lat: 44.0214, lon: 153.6819, depth: 47, url: "", time: "October 13, 1963"),
        Earthquake(id: "10", mag: 8.5, MMI: 6, sig: nil, loc: "Indonesia, Banda Sea", place: "Banda Sea", lat: -6.7836, lon: 129.8606, depth: 60, url: "", time: "February 1, 1938"),
        Earthquake(id: "11", mag: 8.5, MMI: 11, sig: nil, loc: "Chile, Atacama", place: "Chile", lat: -27.0345, lon: -70.4368, depth: 70, url: "", time: "November 10, 1922"),
        Earthquake(id: "12", mag: 8.5, MMI: nil, sig: nil, loc: "Western Samoa", place: "Western Samoa", lat: -13.7590, lon: -172.1046, depth: 10, url: "", time: "June 25, 1917"),
        Earthquake(id: "13", mag: 9.2, MMI: 9, sig: nil, loc: "Indonesia, Sumatra, Indian Ocean", place: "Sumatra", lat: 3.3166, lon: 95.8558, depth: 30, url: "", time: "December 26, 2004"),
        Earthquake(id: "14", mag: 9.0, MMI: 11, sig: nil, loc: "Japan, Tōhoku, Pacific Ocean", place: "Tōhoku", lat: 38.3228, lon: 142.3734, depth: 29, url: "", time: "March 11, 2011"),
        Earthquake(id: "15", mag: 8.8, MMI: 9, sig: nil, loc: "Chile, Maule", place: "Chile", lat: -35.7010, lon: -71.7984, depth: 35, url: "", time: "February 27, 2010"),
        Earthquake(id: "16", mag: 8.6, MMI: 8, sig: nil, loc: "Indonesia, Sumatra", place: "Sumatra", lat: 1.1603, lon: 99.8789, depth: 30, url: "", time: "March 28, 2005"),
        Earthquake(id: "17", mag: 8.6, MMI: 7, sig: nil, loc: "Indonesia, Sumatra", place: "Sumatra", lat: 1.1603, lon: 99.8789, depth: 20, url: "", time: "April 11, 2012"),
        Earthquake(id: "18", mag: 8.5, MMI: 6, sig: nil, loc: "Indonesia, Sumatra", place: "Sumatra", lat: 1.1603, lon: 99.8789, depth: 34, url: "", time: "September 12, 2007")
    ]
    @State private var historicalSelect: Bool = true
    @State private var pastSelect: Bool = true
    @State private var dataRange: Int = 0 // 0: past 24h, 1: past week, 2: past month
    @State private var selectedEarthquakeID: String? = nil
    @State private var isLoading: Bool = false
    @State private var showLargeDataWarning: Bool = false

    var body: some View {
        ZStack {
            NavigationSplitView {
                SidebarView(earthquakes: $earthquakes, historicEarthquakes: $historicEarthquakes, pastSelect: $pastSelect, historicalSelect: $historicalSelect, dataRange: $dataRange, selectedEarthquakeID: $selectedEarthquakeID)
            } detail: {
                ZStack {
                    EarthView(earthquakes: $earthquakes, historicEarthquakes: $historicEarthquakes, pastSelect: $pastSelect, historicalSelect: $historicalSelect, dataRange: $dataRange, selectedEarthquakeID: $selectedEarthquakeID, isLoading: $isLoading)
                }
            }
            .toolbar {
                if #available(macOS 26.0, *) {
                    GlassEffectContainer(spacing: 20) {
                        HStack(spacing: 20) {
                            HStack {
                                Button {
                                    withAnimation {
                                        isLoading = true
                                    }
                                    EarthView(earthquakes: $earthquakes, historicEarthquakes: $historicEarthquakes, pastSelect: $pastSelect, historicalSelect: $historicalSelect, dataRange: $dataRange, selectedEarthquakeID: $selectedEarthquakeID, isLoading: $isLoading).fetchEarthquakeData()
                                    withAnimation {
                                        isLoading = false
                                    }
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .imageScale(.large)
                                        .symbolRenderingMode(.monochrome)
                                        .foregroundStyle(.primary)
                                        .font(.subheadline)
                                        .padding()
                                }
                                Button(action: {
                                    let settingsPanel = createSettingsPanel(historicalSelect: $historicalSelect, pastSelect: $pastSelect)
                                    settingsPanel?.makeKeyAndOrderFront(nil)
                                }) {
                                    Image(systemName: "gear")
                                        .imageScale(.large)
                                        .symbolRenderingMode(.monochrome)
                                        .foregroundStyle(.primary)
                                        .font(.subheadline)
                                        .padding()
                                }
                            }
                            .glassEffect()
                            .glassEffectID("permanent", in: namespace)
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaleEffect(0.6)
                                    .frame(width: 28, height: 28)
                                    .padding(.trailing, 6)
    //                                .glassEffect()
                                    .glassEffectID("loading", in: namespace)
                            }
                        }
                    }
                } else {
                    HStack(spacing: 20) {
                        HStack {
                            Button {
                                withAnimation {
                                    isLoading = true
                                }
                                EarthView(earthquakes: $earthquakes, historicEarthquakes: $historicEarthquakes, pastSelect: $pastSelect, historicalSelect: $historicalSelect, dataRange: $dataRange, selectedEarthquakeID: $selectedEarthquakeID, isLoading: $isLoading).fetchEarthquakeData()
                                withAnimation {
                                    isLoading = false
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .imageScale(.large)
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(.primary)
                                    .font(.subheadline)
                                    .padding()
                            }
                            Button(action: {
                                let settingsPanel = createSettingsPanel(historicalSelect: $historicalSelect, pastSelect: $pastSelect)
                                settingsPanel?.makeKeyAndOrderFront(nil)
                            }) {
                                Image(systemName: "gear")
                                    .imageScale(.large)
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(.primary)
                                    .font(.subheadline)
                                    .padding()
                            }
                        }
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(0.8)
                                .frame(width: 28, height: 28)
                        }
                    }
                }
            }
            .onChange(of: dataRange, initial: true) {
                if dataRange >= 1 {
                    withAnimation(.easeInOut) { showLargeDataWarning = true }
                } else {
                    withAnimation(.easeInOut) { showLargeDataWarning = false }
                }
            }
            .onAppear {
                if dataRange >= 1 {
                    showLargeDataWarning = true
                }
            }
            
            if showLargeDataWarning {
                VStack {
                    Spacer()
                    if #available(macOS 26.0, *) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                            Text("Selected dataset is large. Loading delays are to be expected.")
                                .font(.callout)
                            Spacer(minLength: 8)
                            Button {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    showLargeDataWarning = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .glassEffect(.regular)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .frame(maxWidth: 500)
                        .padding(.bottom, 20)
                        .allowsHitTesting(true)
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                            Text("Selected dataset is large. Loading delays are to be expected.")
                                .font(.callout)
                            Spacer(minLength: 8)
                            if #available(macOS 26.0, *) {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        showLargeDataWarning = false
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .buttonStyle(.glassProminent)
                            } else {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        showLargeDataWarning = false
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .bold))
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .frame(maxWidth: 500)
                        .padding(.bottom, 20)
                        .allowsHitTesting(true)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: showLargeDataWarning)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .allowsHitTesting(false)
            }
        }
    }
    
    private func createSettingsPanel(historicalSelect: Binding<Bool>, pastSelect: Binding<Bool>) -> NSPanel? {
        if settingsPanel == nil {
            let panel = NSPanel(contentRect: NSRect(x:0,y:0,width:450,height:450), styleMask: [.unifiedTitleAndToolbar, .borderless, .titled, .closable, .hudWindow, .utilityWindow], backing: .buffered, defer: false)
            
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.hidesOnDeactivate = true
            panel.isReleasedWhenClosed = false
            panel.title = "Settings"
            panel.contentView = NSHostingView(rootView: SettingsView(pastSelect: $pastSelect, historicalSelect: $historicalSelect, dataRange: $dataRange))//, MBEVisible: $MBEVisible))
            
            panel.isOpaque = false
            panel.backgroundColor = .clear
            
            settingsPanel=panel
            
            panel.makeKeyAndOrderFront(nil)
            panel.center()
            
            
            return panel
        } else {
            settingsPanel?.makeKeyAndOrderFront(nil)
            return settingsPanel!
        }
    }
}

#Preview {
    ContentView()
        .background(Color.black.background(.ultraThinMaterial))
}

