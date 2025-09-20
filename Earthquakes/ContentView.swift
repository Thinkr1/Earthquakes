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

//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let manager = CLLocationManager()
//    
//    @Published var loc: CLLocationCoordinate2D?
//
//    @Published var authorizationStatus: CLAuthorizationStatus?
//
//    override init() {
//        super.init()
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//    }
//    
//    func requestLocation() {
//        manager.requestWhenInUseAuthorization()
//        if CLLocationManager.locationServicesEnabled() {
//            manager.startUpdatingLocation()
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
//        guard let loct = locs.first else { return }
//        self.loc = loct.coordinate
//        manager.stopUpdatingLocation()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        self.authorizationStatus = status
//        manager.startUpdatingLocation()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Failed to find user's location: \(error.localizedDescription)")
//    }
//}

struct ContentView: View {
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
    @State private var HistoricalSelect: Bool = true
    @State private var PastSelect: Bool = true
    @State private var dataRange: Int = 0 // 0: past 24h, 1: past week, 2: past month
    @State private var selectedEarthquakeID: String? = nil
    
    var body: some View {
        ZStack {
            NavigationSplitView {
                SidebarView(earthquakes: $earthquakes, historicEarthquakes: $historicEarthquakes, PastSelect: $PastSelect, HistoricalSelect: $HistoricalSelect, dataRange: $dataRange, selectedEarthquakeID: $selectedEarthquakeID)
            } detail: {
                EarthView(earthquakes: $earthquakes, historicEarthquakes: $historicEarthquakes, PastSelect: $PastSelect, HistoricalSelect: $HistoricalSelect, dataRange: $dataRange, selectedEarthquakeID: $selectedEarthquakeID)
            }
//            if #available(macOS 26.0, *) {
//                Color.clear
//                    .glassEffect(.regular)
//                    .ignoresSafeArea()
//            }
        }
        .toolbar {
            ToolbarItem(id:"refresh", placement: .automatic) {
                HStack {
                    Button(action:  EarthView(earthquakes: $earthquakes, historicEarthquakes: $historicEarthquakes, PastSelect: $PastSelect, HistoricalSelect: $HistoricalSelect, dataRange: $dataRange, selectedEarthquakeID: $selectedEarthquakeID).fetchEarthquakeData) {
                        Image(systemName: "arrow.clockwise")
                            .imageScale(.large)
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(.primary)
                            .font(.subheadline)
                            .padding()
                    }
                    Spacer()
                }
            }
            ToolbarItem(id:"settings", placement: .automatic) {
                HStack {
                    Button(action: {
                        let settingsPanel = createSettingsPanel(HistoricalSelect: $HistoricalSelect, PastSelect: $PastSelect)
                        settingsPanel?.makeKeyAndOrderFront(nil)
                    }) {
                        Image(systemName: "gear")
                            .imageScale(.large)
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(.primary)
                            .font(.subheadline)
                            .padding()
                    }
                    Spacer()
                }
            }
        }
        .toolbarRole(.automatic)
        .toolbarTitleDisplayMode(.inline)
        .background(
            Group {
                if #available(macOS 26.0, *) {
                    Color.clear.glassEffect(.regular)
                } else {
                    Color.clear
                }
            }
        )
        
        
//        MenuBarExtra("Earthquakes", isInserted: $MBEVisible) {
//            Text("Earthquakes today: \(earthquakes.count)")
//                .padding()
//            Text("Earthquakes near you today: \(earthquakesNearLoc)")
//            Divider()
//            Button(action: {
//                let settingsPanel = createSettingsPanel(HistoricalSelect: $HistoricalSelect, PastSelect: $PastSelect)
//                settingsPanel?.makeKeyAndOrderFront(nil)
//            }) {
//                Text("Settings")
//            }
//            Button(action: {
//                NSApplication.shared.terminate(nil)
//            }) {
//                Text("Quit")
//            }
//        }
    }
    
    private func createSettingsPanel(HistoricalSelect: Binding<Bool>, PastSelect: Binding<Bool>) -> NSPanel? {
        if settingsPanel == nil {
            let panel = NSPanel(contentRect: NSRect(x:0,y:0,width:450,height:450), styleMask: [.unifiedTitleAndToolbar, .borderless, .titled, .closable, .hudWindow, .utilityWindow], backing: .buffered, defer: false)
            
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.hidesOnDeactivate = true
            panel.isReleasedWhenClosed = false
            panel.title = "Settings"
            panel.contentView = NSHostingView(rootView: SettingsView(PastSelect: $PastSelect, HistoricalSelect: $HistoricalSelect, dataRange: $dataRange))//, MBEVisible: $MBEVisible))
            
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

struct SidebarView: View {
    @Binding var earthquakes: [Earthquake]
    @Binding var historicEarthquakes: [Earthquake]
    @Binding var PastSelect: Bool
    @Binding var HistoricalSelect: Bool
    @Binding var dataRange: Int
    @Binding var selectedEarthquakeID: String?
    @State private var selectedEarthquake: Earthquake? = nil
    @State private var showPopover: Bool=false

    var body: some View {
        List {
            if PastSelect {
                pastDaySection()
            }
            if HistoricalSelect {
                historicalSection()
            }
            
        }
        .listStyle(SidebarListStyle())
        .background(Color.clear.background(.thinMaterial))
        .navigationTitle("Earthquakes")
//        .onAppear {
//            if let id=selectedEarthquakeID {
//                if let i=earthquakes.firstIndex(where: {$0.id==id}) {
//                    self.selectedEarthquake = earthquakes[i]
//                } else if let i=historicEarthquakes.firstIndex(where: {$0.id==id}) {
//                    self.selectedEarthquake = historicEarthquakes[i]
//                }
//            }
//        }
    }
    
    @ViewBuilder
    private func historicalSection() -> some View {
        Section("Historic Earthquakes") {
            ForEach(historicEarthquakes, id: \.id) { e in
                historicalSectionRow(e)
            }
        }
    }
    
    private func historicalSectionRow(_ e: Earthquake) -> some View {
        Button(action: {
            selectedEarthquake = e
            showPopover = true
        }){
            HStack {
                Circle()
                    .fill(getColor(for: e.mag))
                    .frame(width: 20, height: 20)
                VStack(alignment: .leading) {
                    Text("\(e.mag, specifier: "%.1f")")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.primary)
                    Text(e.loc)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                }
            }
        }
        .popover(isPresented: Binding(get: {
            showPopover && selectedEarthquake == e
        }, set: {
            if !$0 {showPopover=false}
        })) {
            if let se = selectedEarthquake {
                historicalSectionRowPopoverContent(se)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func historicalSectionRowPopoverContent(_ se: Earthquake) -> some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            if #available(macOS 14.0, *) {
                Text("Earthquake: ").foregroundStyle(.secondary)+Text(se.loc).foregroundStyle(.primary).bold()
                    .font(.headline)
                    .bold()
                //.padding(.bottom, 5)
                Text("Magnitude: ").foregroundStyle(.secondary)+Text("\(se.mag, specifier: "%.1f")").foregroundStyle(.primary).bold()
                Text("Date: ").foregroundStyle(.secondary)+Text(se.time).foregroundStyle(.primary).bold()
            } else {
                Text("Earthquake: ").foregroundColor(.secondary)+Text(se.loc).foregroundColor(.primary).bold()
                    .font(.headline)
                    .bold()
                //.padding(.bottom, 5)
                Text("Magnitude: ").foregroundColor(.secondary)+Text("\(se.mag, specifier: "%.1f")").foregroundColor(.primary).bold()
                Text("Date: ").foregroundColor(.secondary)+Text(se.time).foregroundColor(.primary).bold()
            }
            if se.MMI != nil {
                LazyHStack {
                    Text("MMI: ").foregroundColor(.secondary)
                    Text(getMMIText(for: se.MMI))
                        .bold()
                        .padding(2)
                        .background(getMMIColor(for: se.MMI))
                        .foregroundColor(getMMITextColor(for: se.MMI))
                }
                Divider()
                Text("The maximum intensity is based on the Modified Mercalli intensity (MMI) scale which measures the effects of an earthquake at a given location.").font(.footnote).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.clear.background(.thickMaterial))
        .frame(width: 200)
    }
    
    @ViewBuilder
    private func pastDaySection() -> some View {
        Section("Past \(dataRange==0 ? "24h" : dataRange==1 ? "7d" : "Month") (\(earthquakes.count))") {
            ForEach(earthquakes, id: \.id) { e in
                pastDaySectionRow(e)
            }
        }
    }
    
    private func pastDaySectionRow(_ e: Earthquake) -> some View {
        Button(action: {
            selectedEarthquake = e
            showPopover = true
        }){
            HStack {
                Circle()
                    .fill(getColor(for: e.mag))
                    .frame(width: 20, height: 20)
                    .overlay {
                        Text("\(e.mag, specifier: "%.1f")")
                            .font(.system(size: 7.5))
                            .foregroundStyle(.black)
                            .fontWeight(.black)
                    }
                VStack(alignment: .leading) {
                    Text(e.place)
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.primary)
//                                    Text("\(e.mag, specifier: "%.1f")")
//                                        .font(.subheadline)
//                                        .bold()
//                                        .foregroundStyle(.primary)
                    Text(e.loc)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                }
            }
        }
        .popover(isPresented: Binding(get: {
            showPopover && selectedEarthquake == e
        }, set: {
            if !$0 {showPopover=false}
        })) {
            if let se = selectedEarthquake {
                pastDaySectionRowPopoverContent(se)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func pastDaySectionRowPopoverContent(_ se: Earthquake) -> some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            if #available(macOS 14.0, *) {
                Text("ID: ").foregroundStyle(.secondary)+Text(se.id).foregroundStyle(.primary).bold()
                    .font(.headline)
                    .bold()
            
                if se.sig != nil {Text("Significance: ").foregroundStyle(.secondary)+Text("\(se.sig ?? 0, specifier: "%.f")/1000").foregroundStyle(.primary).bold()}
                Text("Magnitude: ").foregroundStyle(.secondary)+Text("\(se.mag, specifier: "%.1f")").foregroundStyle(.primary).bold()
                Text("Location: ").foregroundStyle(.secondary)+Text(se.loc).foregroundStyle(.primary).bold()
                Text("UTC Time: ").foregroundStyle(.secondary)+Text(se.time).foregroundStyle(.primary).bold()
                Text("Depth: ").foregroundStyle(.secondary)+Text("\(se.depth, specifier: "%.1f") km").foregroundStyle(.primary).bold()
            } else {
                Text("ID: ").foregroundColor(.secondary)+Text(se.id).foregroundColor(.primary).bold()
                    .font(.headline)
                    .bold()
            
                if se.sig != nil {Text("Significance: ").foregroundColor(.secondary)+Text("\(se.sig ?? 0, specifier: "%.f")/1000").foregroundColor(.primary).bold()}
                Text("Magnitude: ").foregroundColor(.secondary)+Text("\(se.mag, specifier: "%.1f")").foregroundColor(.primary).bold()
                Text("Location: ").foregroundColor(.secondary)+Text(se.loc).foregroundColor(.primary).bold()
                Text("UTC Time: ").foregroundColor(.secondary)+Text(se.time).foregroundColor(.primary).bold()
                Text("Depth: ").foregroundColor(.secondary)+Text("\(se.depth, specifier: "%.1f") km").foregroundColor(.primary).bold()
            }
            if se.MMI != nil {
                LazyHStack {
                    Text("Max Intensity: ").foregroundColor(.secondary)
                    Text(getMMIText(for: se.MMI))
                        .bold()
                        .padding(2)
                        .background(getMMIColor(for: se.MMI))
                        .foregroundColor(getMMITextColor(for: se.MMI))
                }
            }
            Link("More info (USGS)", destination: URL(string: se.url)!)
                .underline()
            if se.MMI != nil || se.sig != nil {
                Divider()
                DisclosureGroup("Comments") {
                    if se.MMI != nil && se.sig != nil {
                        Text("The maximum intensity is based on the Modified Mercalli intensity (MMI) scale which measures the effects of an earthquake at a given location.\n\nThe significance (on a scale of 0 to 1000) is determined on a number of factors, including: magnitude, maximum MMI, felt reports, and estimated impact.").font(.footnote).foregroundStyle(.secondary) // cdi (not mmi) is fetched because it represents the MAX intensity
                    }
                    if se.sig != nil && se.MMI == nil {
                        Text("The significance (on a scale of 0 to 1000) is determined on a number of factors, including: magnitude, maximum MMI, felt reports, and estimated impact.").font(.footnote).foregroundStyle(.secondary)
                    }
                    if se.MMI != nil && se.sig == nil {
                        Text("The maximum intensity is based on the Modified Mercalli intensity (MMI) scale which measures the effects of an earthquake at a given location.").font(.footnote).foregroundStyle(.secondary) // cdi (not mmi) is fetched because it represents the MAX intensity
                    }
                }
            }
        }
        .padding()
        .background(Color.clear.background(.thickMaterial))
        .frame(width: 275)
    }
    
    private func getColor(for mag: Double) -> Color {
        switch mag {
        case _ where mag >= 7:
            return Color(red: 117 / 255.0, green: 20 / 255.0, blue: 12 / 255.0)
        case _ where mag >= 6:
            return Color(red: 249 / 255.0, green: 127 / 255.0, blue: 73 / 255.0)
        case _ where mag >= 5:
            return Color(red: 255 / 255.0, green: 255 / 255.0, blue: 84 / 255.0)
        case _ where mag >= 4:
            return Color(red: 191 / 255.0, green: 253 / 255.0, blue: 91 / 255.0)
        case _ where mag >= 3:
            return Color(red: 175 / 255.0, green: 249 / 255.0, blue: 162 / 255.0)
        case _ where mag >= 2:
            return Color(red: 188 / 255.0, green: 236 / 255.0, blue: 200 / 255.0)
//        case _ where mag >= 1:
//            return Color(red: 151 / 255.0, green: 204 / 255.0, blue: 246 / 255.0)
        default:
            return Color.white
        }
    }
    
    private func getMMIText(for MMI: Double?) -> String {
        if MMI != nil {
            switch MMI {
            case _ where MMI! >= 12:
                return "XII (Extreme)"
            case _ where MMI! >= 11:
                return "XI (Extreme)"
            case _ where MMI! >= 10:
                return "X (Extreme)"
            case _ where MMI! >= 9:
                return "IX (Violent)"
            case _ where MMI! >= 8:
                return "VIII (Severe)"
            case _ where MMI! >= 7:
                return "VII (Very Strong)"
            case _ where MMI! >= 6:
                return "VI (Strong)"
            case _ where MMI! >= 5:
                return "V (Moderate)"
            case _ where MMI! >= 4:
                return "IV (Light)"
            case _ where MMI! >= 3:
                return "III (Weak)"
            case _ where MMI! >= 2:
                return "II (Weak)"
            case _ where MMI! >= 1:
                return "I (Not felt)"
            case _ where MMI! >= 0:
                return "Not felt"
            default:
                return "–"
            }
        } else {
            return "–"
        }
    }
    
    private func getMMITextColor(for MMI: Double?) -> Color {
        if MMI != nil {
            switch MMI {
            case _ where MMI! >= 9:
                return Color.white
            case _ where MMI! < 9:
                return Color.black
            default:
                return Color.clear
            }
        } else {
            return Color.clear
        }
    }
    
    private func getMMIColor(for MMI: Double?) -> Color {
        if MMI != nil {
            switch MMI {
            case _ where MMI! >= 12:
                return Color(red: 117 / 255.0, green: 20 / 255.0, blue: 12 / 255.0)
            case _ where MMI! >= 11:
                return Color(red: 150 / 255.0, green: 29 / 255.0, blue: 19 / 255.0)
            case _ where MMI! >= 10:
                return Color(red: 183 / 255.0, green: 38 / 255.0, blue: 25 / 255.0)
            case _ where MMI! >= 9:
                return Color(red: 234 / 255.0, green: 51 / 255.0, blue: 35 / 255.0)
            case _ where MMI! >= 8:
                return Color(red: 240 / 255.0, green: 150 / 255.0, blue: 55 / 255.0)
            case _ where MMI! >= 7:
                return Color(red: 246 / 255.0, green: 202 / 255.0, blue: 69 / 255.0)
            case _ where MMI! >= 6:
                return Color(red: 255 / 255.0, green: 255 / 255.0, blue: 84 / 255.0)
            case _ where MMI! >= 5:
                return Color(red: 157 / 255.0, green: 252 / 255.0, blue: 158 / 255.0)
            case _ where MMI! >= 4:
                return Color(red: 161 / 255.0, green: 252 / 255.0, blue: 254 / 255.0)
            case _ where MMI! >= 3:
                return Color(red: 175 / 255.0, green: 228 / 255.0, blue: 252 / 255.0)
            case _ where MMI! >= 2:
                return Color(red: 193 / 255.0, green: 204 / 255.0, blue: 251 / 255.0)
            case _ where MMI! >= 1:
                return Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
            case _ where MMI! >= 0:
                return Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
            default:
                return Color.clear
            }
        } else {
            return Color.clear
        }
    }
}

struct EarthView: View {
    @State private var scene = SCNScene()
//    @State private var selectedEarthquake: Earthquake?
//    @State private var showPopover: Bool = false
//    @State private var popoverAnchor: CGPoint = .zero
    @State private var debounceTimer: Timer?
    @Binding var earthquakes: [Earthquake]
    @Binding var historicEarthquakes: [Earthquake]
    @Binding var PastSelect: Bool
    @Binding var HistoricalSelect: Bool
    @Binding var dataRange: Int
    @Binding var selectedEarthquakeID: String?
    
    var body: some View {
        ZStack {
            if #available(macOS 14.0, *) {
                ZStack {
                    SceneView(
                        scene: scene,
                        options: [.allowsCameraControl, .autoenablesDefaultLighting]
                    )
                    .edgesIgnoringSafeArea(.all)
                }
                .onAppear {
                    setupScene()
                    fetchEarthquakeData()
                }
                .onChange(of: PastSelect, initial: true, {
                    scene.rootNode.childNodes.filter {
                        $0.name?.starts(with: "EPD") ?? false
                    }.forEach {
                        $0.removeFromParentNode()
                    }
                })
                .onChange(of: HistoricalSelect, initial: true, {
                    scene.rootNode.childNodes.filter {
                        $0.name?.starts(with: "EH") ?? false
                    }.forEach {
                        $0.removeFromParentNode()
                    }
                })
                .onChange(of: PastSelect, initial: false, {
                    fetchEarthquakeData()
                })
                .onChange(of: HistoricalSelect, initial: false, {
                    fetchEarthquakeData()
                })
                .onChange(of: dataRange, initial: false, {
                    fetchEarthquakeData()
                })
            } else {
                ZStack {
                    SceneView(
                        scene: scene,
                        options: [.allowsCameraControl, .autoenablesDefaultLighting]
                    )
                    .edgesIgnoringSafeArea(.all)
                }
                .onAppear {
                    setupScene()
                    fetchEarthquakeData()
                }
                .onChange(of: PastSelect) { _ in
                    scene.rootNode.childNodes.filter {
                        $0.name?.starts(with: "EPD") ?? false
                    }.forEach {
                        $0.removeFromParentNode()
                    }
                }
                .onChange(of: HistoricalSelect) { _ in
                    scene.rootNode.childNodes.filter {
                        $0.name?.starts(with: "EH") ?? false
                    }.forEach {
                        $0.removeFromParentNode()
                    }
                }
                .onChange(of: PastSelect) { _ in
                    fetchEarthquakeData()
                }
                .onChange(of: HistoricalSelect) { _ in
                    fetchEarthquakeData()
                }
                .onChange(of: dataRange) { _ in
                    fetchEarthquakeData()
                }
            }
//            .tapGesture { event in
//                let loc = event.loc(in: scene)
//                let hitTestResults = scene.hitTest(loc, options: nil)
//                if let node = hitTestResults.first?.node {
//                    selectedEarthquakeID = node.name?.split(separator: "_")[1]
//                }
//            }
        }
//        .popover(isPresented: $showPopover, arrowEdge: .top) {
//            if let e = selectedEarthquake {
//                VStack {
//                    Text("ID: ").foregroundStyle(.secondary)+Text(e.id).foregroundStyle(.primary).bold()
//                        .font(.headline)
//                        .bold()
//                    Text("Magnitude: ").foregroundStyle(.secondary)+Text("\(e.mag, specifier: "%.1f")").foregroundStyle(.primary).bold()
//                    Button("Close") {
//                        showPopover=false
//                    }
//                }
//                .padding()
//                .frame(width: 275)
//            }
//        }
    }
    
    func setupScene() {
        scene.background.contents = "black.stars"
        
        let earthNode = createEarthNode()
        scene.rootNode.addChildNode(earthNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = false
        cameraNode.camera?.fieldOfView = 65
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        scene.rootNode.addChildNode(cameraNode)
    }
    
    func fetchEarthquakeData() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.fetchEarthquakeDataDebounce()
        }
    }
    
    func fetchEarthquakeDataDebounce() {
        let urlString: String
        // Geological data provided by the U.S. Geological Survey (USGS)
        switch dataRange {
        case 0:
            urlString = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
        case 1:
            urlString = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson"
        default:
            urlString = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson"
        }
        
        guard let url = URL(string: urlString) else {return}
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        let session = URLSession(configuration: config)
        
       session.dataTask(with: url) { data, _, error in
            guard let data=data, error==nil else { return }
            print("fetched data")
            do {
                if let geoJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any], let features = geoJSON["features"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        print("updating")
                        self.updateEarquakeList(features)
                        let select = PastSelect && !HistoricalSelect ? 0 : HistoricalSelect && !PastSelect ? 1 : 2
                        self.updateEarthquakePins(features, select)
                    }
                }
            } catch {
                print("Failed to parse GeoJSON: \(error)")
            }
        }.resume()
    }
    
    func updateEarquakeList(_ features: [[String: Any]]) {
        var nEarthquakes: [Earthquake] = []
        for feature in features {
            if let properties = feature["properties"] as? [String: Any], let mag=properties["mag"] as? Double, let place=properties["place"] as? String, let url=properties["url"] as? String, let eid=feature["id"] as? String, let time=properties["time"] as? Int64, let geo = feature["geometry"] as? [String: Any], let coords = geo["coordinates"] as? [Double], let sig = properties["sig"] as? Double {
                
                let MMI: Double? = {
                    if let mmi = properties["cdi"] {
                        return mmi is NSNull ? nil : mmi as? Double
                    }
                    return nil
                }()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                //formatter.timeZone = TimeZone(abbreviation: "UTC")
                let formattedTime = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(time / 1000)))
                
                let stateRegex = /of (.*)/
                
                var state = place.capitalized
                
                do {
                    if let stateMatch = try stateRegex.firstMatch(in: place) {
                        state = String(String(stateMatch.0).dropFirst(3))
                    } else {
                        state = place.capitalized
                    }
                } catch {
                    print("Failed to found state in \(place.capitalized)")
                }
                
                nEarthquakes.append(Earthquake(id: eid, mag: mag, MMI: MMI, sig: sig, loc: place, place: state, lat:coords[1], lon:coords[0], depth: coords[2], url: url, time: formattedTime))
            }
        }
        self.earthquakes = nEarthquakes
        //print(nEarthquakes)
    }
    
    func updateEarthquakePins(_ features: [[String: Any]], _ select: Int) { // 0: Past x, 1: Historical, 2: both
        scene.rootNode.childNodes.filter {
            $0.name?.starts(with: "E") ?? false
        }.forEach {
            $0.removeFromParentNode()
        }
        
        if select==0 || select==2 {
            for feature in features {
                if let geo = feature["geometry"] as? [String: Any], let coord = geo["coordinates"] as? [Double], coord.count>=2, let properties = feature["properties"] as? [String: Any], let mag=properties["mag"] as? Double, let id=feature["id"] {
                    //print("Adding pin at \(coord[1]),\(coord[0])")
                    addEarthquakePin(lat:coord[1], lon:coord[0], mag:mag, id:id as! String, first: "PD")
                }
            }
        }
        
        if select==1 || select==2 {
            for e in historicEarthquakes {
                addEarthquakePin(lat: e.lat!, lon: e.lon!, mag: e.mag, id: e.id, first: "H")
            }
        }

    }
    
    func addEarthquakePin(lat:Double, lon:Double, mag:Double, id:String, first:String) {
        let pinNode = createPinNode(color: mag>=7 ? NSColor(red: 117/255.0, green: 20/255.0, blue: 12/255.0, alpha: 1) : mag>=6 ? NSColor(calibratedRed: 249/255.0, green: 127/255.0, blue: 73/255.0, alpha: 1) : mag>=5 ? NSColor(calibratedRed: 255/255.0, green: 255/255.0, blue: 84/255.0, alpha: 1) : mag>=4 ? NSColor(calibratedRed: 191/255.0, green: 253/255.0, blue: 91/255.0, alpha: 1) : mag>=3 ? NSColor(calibratedRed: 175/255.0, green: 249/255.0, blue: 162/255.0, alpha: 1) : mag>=2 ? NSColor(calibratedRed: 188/255.0, green: 236/255.0, blue: 237/255.0, alpha: 1) : NSColor(calibratedRed: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1))
        pinNode.position = convertCoordinatesTo3D(lat: lat, lon: lon)
        pinNode.name = "E\(first)EarthquakePin_\(id)"
//        pinNode.selectHandler = {
//            self.selectedEarthquakeID = id
//        }
        
        scene.rootNode.addChildNode(pinNode)
    }
    
    func createPinNode(color: NSColor = NSColor.white) -> SCNNode {
        let sphere = SCNSphere(radius: 0.012)
        sphere.firstMaterial?.diffuse.contents = color
        
        let pinNode = SCNNode(geometry: sphere)
        pinNode.position = SCNVector3(0,0.05,0)
        
        return pinNode
    }
    
    func convertCoordinatesTo3D(lat:Double, lon:Double) -> SCNVector3 {
        let rad: Float=1.2 // =Earth
        let latRad = Float(lat) * .pi / 180
        let lonRad = Float(-lon) * .pi / 180
        
        let x=rad*cos(latRad)*cos(lonRad + .pi / 2)
        let y=rad*sin(latRad)
        let z=rad*cos(latRad)*sin(lonRad + .pi / 2)
        
        return SCNVector3(x,y,z)
    }
    
    func createEarthNode() -> SCNNode {
        let sphere = SCNSphere(radius: 1.2)
        
        let material = SCNMaterial()
        material.diffuse.contents = "world.topo.bathy" // Source: NASA
        material.diffuse.wrapT = .repeat
        // Mildly sharpen texture rendering without pixelation
        material.diffuse.minificationFilter = .linear
        material.diffuse.magnificationFilter = .linear
        material.diffuse.mipFilter = .linear
        material.specular.contents = Color.gray
        sphere.materials = [material]
        
        let earthNode = SCNNode(geometry: sphere)
//        let rotateAction = SCNAction.rotateBy(x:0, y:.pi*2, z:0, duration: 45)
//        let repeatRotation = SCNAction.repeatForever(rotateAction)
//        earthNode.runAction(repeatRotation)
        
        return earthNode
    }
}

struct SettingsView: View {
    @Binding var PastSelect: Bool
    @Binding var HistoricalSelect: Bool
    @Binding var dataRange: Int
    
    var body: some View {
        VStack {
//            Text("Settings")
//                .font(.headline)
//                .bold()
//                .padding(.top, 10)
            HStack {
                Text("Show: ")
                    .padding()
                if #available(macOS 14.0, *) {
                    Toggle("Past \(dataRange==0 ? "Day" : dataRange==1 ? "Week" : "Month")", isOn: $PastSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: PastSelect, initial: false) {
                            if !HistoricalSelect && !PastSelect {
                                PastSelect=true
                            }
                        }
                    Toggle("Historical", isOn: $HistoricalSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: HistoricalSelect, initial: false) {
                            if !PastSelect && !HistoricalSelect {
                                HistoricalSelect=true
                            }
                        }
                } else {
                    Toggle("Past \(dataRange==0 ? "Day" : dataRange==1 ? "Week" : "Month")", isOn: $PastSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: PastSelect) { _ in
                            if !HistoricalSelect && !PastSelect {
                                PastSelect=true
                            }
                        }
                    Toggle("Historical", isOn: $HistoricalSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: HistoricalSelect) { _ in
                            if !PastSelect && !HistoricalSelect {
                                HistoricalSelect=true
                            }
                        }
                }
            }.padding()
        }
        .padding(.top)
//        .background(Color.clear.background(.regularMaterial))
//        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        Picker("Data range: ", selection: $dataRange) {
            HStack {
                Text("Past Day")
            }.tag(0)
            HStack {
                Text("Past Week")
                Image(systemName: "exclamationmark.triangle")
            }.tag(1)
            HStack {
                Text("Past Month")
                Image(systemName: "exclamationmark.triangle")
            }.tag(2)
        }.padding(.bottom)
        HStack {
            if #available(macOS 15.0, *) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                    .symbolEffect(.wiggle.up.byLayer, options: .repeat(.periodic(delay: 1.0)))
            } else {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
            }
            Text("Due to its extensive size, data may take more time to load")
        }.padding()
    }
}

#Preview {
    ContentView()
        .background(Color.black.background(.ultraThinMaterial))
}

