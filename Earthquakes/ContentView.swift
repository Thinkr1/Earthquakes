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
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: showLargeDataWarning)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .allowsHitTesting(true)
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

struct SidebarView: View {
    @Binding var earthquakes: [Earthquake]
    @Binding var historicEarthquakes: [Earthquake]
    @Binding var pastSelect: Bool
    @Binding var historicalSelect: Bool
    @Binding var dataRange: Int
    @Binding var selectedEarthquakeID: String?
    @State private var selectedEarthquake: Earthquake? = nil
    @State private var showPopover: Bool=false
    
    var body: some View {
        List {
            if pastSelect {
                pastDaySection()
            }
            if historicalSelect {
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
    @Binding var pastSelect: Bool
    @Binding var historicalSelect: Bool
    @Binding var dataRange: Int
    @Binding var selectedEarthquakeID: String?
    @Binding var isLoading: Bool
    
    private static let pinGeo: SCNSphere = {
        let sphere = SCNSphere(radius: 0.012)
        return sphere
    }()
    
    private static let materialCache: [String: SCNMaterial] = {
        var cache: [String: SCNMaterial] = [:]
        let colors = [
            "red": NSColor(red: 117/255.0, green: 20/255.0, blue: 12/255.0, alpha: 1),
            "orange": NSColor(red: 249/255.0, green: 127/255.0, blue: 73/255.0, alpha: 1),
            "yellow": NSColor(red: 255/255.0, green: 255/255.0, blue: 84/255.0, alpha: 1),
            "lightgreen": NSColor(red: 191/255.0, green: 253/255.0, blue: 91/255.0, alpha: 1),
            "green": NSColor(red: 175/255.0, green: 249/255.0, blue: 162/255.0, alpha: 1),
            "lightblue": NSColor(red: 188/255.0, green: 236/255.0, blue: 237/255.0, alpha: 1),
            "white": NSColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        ]
        
        for (key, color) in colors {
            let material = SCNMaterial()
            material.diffuse.contents = color
            cache[key] = material
        }
        return cache
    }()
    
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
                .onChange(of: pastSelect, initial: true, {
                    scene.rootNode.childNodes.filter {
                        $0.name?.starts(with: "EPD") ?? false
                    }.forEach {
                        $0.removeFromParentNode()
                    }
                })
                .onChange(of: historicalSelect, initial: true, {
                    scene.rootNode.childNodes.filter {
                        $0.name?.starts(with: "EH") ?? false
                    }.forEach {
                        $0.removeFromParentNode()
                    }
                })
                .onChange(of: pastSelect, initial: false, {
                    fetchEarthquakeData()
                })
                .onChange(of: historicalSelect, initial: false, {
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
                .onChange(of: pastSelect) { _ in
                    scene.rootNode.childNodes.filter {
                        $0.name?.starts(with: "EPD") ?? false
                    }.forEach {
                        $0.removeFromParentNode()
                    }
                }
                .onChange(of: historicalSelect) { _ in
                    scene.rootNode.childNodes.filter {
                        $0.name?.starts(with: "EH") ?? false
                    }.forEach {
                        $0.removeFromParentNode()
                    }
                }
                .onChange(of: pastSelect) { _ in
                    fetchEarthquakeData()
                }
                .onChange(of: historicalSelect) { _ in
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
        isLoading = true
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
        
        Task.detached(priority: .userInitiated) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let any = try JSONSerialization.jsonObject(with: data)
                guard let geoJSON = any as? [String: Any], let features = geoJSON["features"] as? [[String: Any]] else {
                    await MainActor.run { self.isLoading = false }
                    return
                }

                let chunkSize = 100
                let chunks = features.chunked(chunkSize)
                var totalCount = 0

                for c in chunks {
                    let chunkRes = await self.processFeatChunk(c)
                    totalCount += chunkRes.count

                    if totalCount % (chunkSize * 2) == 0 {
                        await MainActor.run {
                            var existing = self.earthquakes
                            let existingIDs = Set(existing.map { $0.id })
                            let newOnes = chunkRes.filter { !existingIDs.contains($0.id) }
                            existing.append(contentsOf: newOnes)
                            self.earthquakes = existing
                        }
                    } else {
                        await MainActor.run {
                            var existing = self.earthquakes
                            let existingIDs = Set(existing.map { $0.id })
                            let newOnes = chunkRes.filter { !existingIDs.contains($0.id) }
                            existing.append(contentsOf: newOnes)
                            self.earthquakes = existing
                        }
                    }
                }

                await MainActor.run {
                    let select = self.pastSelect && !self.historicalSelect ? 0 : self.historicalSelect && !self.pastSelect ? 1 : 2
                    self.updateEarthquakePins(features, select)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func processFeatChunk(_ features: [[String: Any]]) -> [Earthquake] {
        var earthquakes: [Earthquake] = []
        
        for feature in features {
            if let properties = feature["properties"] as? [String: Any],
               let mag = properties["mag"] as? Double,
               let place = properties["place"] as? String,
               let url = properties["url"] as? String,
               let eid = feature["id"] as? String,
               let time = properties["time"] as? Int64,
               let geo = feature["geometry"] as? [String: Any],
               let coords = geo["coordinates"] as? [Double],
               let sig = properties["sig"] as? Double {
                
                let MMI: Double? = {
                    if let mmi = properties["cdi"] {
                        return mmi is NSNull ? nil : mmi as? Double
                    }
                    return nil
                }()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
                
                earthquakes.append(Earthquake(
                    id: eid,
                    mag: mag,
                    MMI: MMI,
                    sig: sig,
                    loc: place,
                    place: state,
                    lat: coords[1],
                    lon: coords[0],
                    depth: coords[2],
                    url: url,
                    time: formattedTime
                ))
            }
        }
        
        return earthquakes
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
        let nToRemove = scene.rootNode.childNodes.filter {
            $0.name?.starts(with: "E") ?? false
        }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0
        nToRemove.forEach {$0.removeFromParentNode()}
        SCNTransaction.commit()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var pinNodes: [SCNNode] = []
            
            if select==0 || select==2 {
                for feature in features {
                    if let geo = feature["geometry"] as? [String: Any], let coord = geo["coordinates"] as? [Double], coord.count>=2, let properties = feature["properties"] as? [String: Any], let mag=properties["mag"] as? Double, let id=feature["id"] {
                        //print("Adding pin at \(coord[1]),\(coord[0])")
                        //                        addEarthquakePin(lat:coord[1], lon:coord[0], mag:mag, id:id as! String, first: "PD")
                        let pinNode = self.createPinNode(
                            color: self.getMagColor(mag),
                            position: self.convertCoordinatesTo3D(lat: coord[1], lon: coord[0]),
                            id: "EPDEarthquakePin_\(id)"
                        )
                        pinNodes.append(pinNode)
                    }
                }
            }
            
            if select == 1 || select == 2 {
                for e in self.historicEarthquakes {
                    if let lat = e.lat, let lon = e.lon {
                        let node = self.createPinNode(
                            color: self.getMagColor(e.mag),
                            position: self.convertCoordinatesTo3D(lat: lat, lon: lon),
                            id: "EHEarthquakePin_\(e.id)"
                        )
                        pinNodes.append(node)
                    }
                }
            }
            
            let batchSize = 50
            for batch in pinNodes.chunked(batchSize) {
                DispatchQueue.main.async {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0
                    batch.forEach { self.scene.rootNode.addChildNode($0) }
                    SCNTransaction.commit()
                }
            }
        }
        
        //        if select==1 || select==2 {
        //            for e in historicEarthquakes {
        //                addEarthquakePin(lat: e.lat!, lon: e.lon!, mag: e.mag, id: e.id, first: "H")
        //            }
        //        }
    }
    
    private func getMagColor(_ mag: Double) -> NSColor {
        switch mag {
        case _ where mag >= 7:
            return NSColor(red: 117/255.0, green: 20/255.0, blue: 12/255.0, alpha: 1)
        case _ where mag >= 6:
            return NSColor(red: 249/255.0, green: 127/255.0, blue: 73/255.0, alpha: 1)
        case _ where mag >= 5:
            return NSColor(red: 255/255.0, green: 255/255.0, blue: 84/255.0, alpha: 1)
        case _ where mag >= 4:
            return NSColor(red: 191/255.0, green: 253/255.0, blue: 91/255.0, alpha: 1)
        case _ where mag >= 3:
            return NSColor(red: 175/255.0, green: 249/255.0, blue: 162/255.0, alpha: 1)
        case _ where mag >= 2:
            return NSColor(red: 188/255.0, green: 236/255.0, blue: 237/255.0, alpha: 1)
        default:
            return NSColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        }
    }
    
    private func getMagColorKey(_ color: NSColor) -> String {
        let red = Int(round(color.redComponent * 255))
        let green = Int(round(color.greenComponent * 255))
        let blue = Int(round(color.blueComponent * 255))
        
        switch (red, green, blue) {
        case (117, 20, 12):
            return "red"
        case (249, 127, 73):
            return "orange"
        case (255, 255, 84):
            return "yellow"
        case (191, 253, 91):
            return "lightgreen"
        case (175, 249, 162):
            return "green"
        case (188, 236, 237):
            return "lightblue"
        default:
            return "white"
        }
    }
    
    func createPinNode(color: NSColor = .white, position: SCNVector3, id: String) -> SCNNode {
        let geo = Self.pinGeo.copy() as! SCNGeometry
        let node = SCNNode(geometry: geo)
        
        let colorKey = getMagColorKey(color)
        if let cachedMaterial = Self.materialCache[colorKey] {
            node.geometry?.materials = [cachedMaterial]
        } else {
            let material = SCNMaterial()
            material.diffuse.contents = color
            node.geometry?.materials = [material]
        }
        
        node.position = position
        node.name = id
        return node
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
    @Binding var pastSelect: Bool
    @Binding var historicalSelect: Bool
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
                    Toggle("Past \(dataRange==0 ? "Day" : dataRange==1 ? "Week" : "Month")", isOn: $pastSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: pastSelect, initial: false) {
                            if !historicalSelect && !pastSelect {
                                pastSelect=true
                            }
                        }
                    Toggle("Historical", isOn: $historicalSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: historicalSelect, initial: false) {
                            if !pastSelect && !historicalSelect {
                                historicalSelect=true
                            }
                        }
                } else {
                    Toggle("Past \(dataRange==0 ? "Day" : dataRange==1 ? "Week" : "Month")", isOn: $pastSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: pastSelect) { _ in
                            if !historicalSelect && !pastSelect {
                                pastSelect=true
                            }
                        }
                    Toggle("Historical", isOn: $historicalSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: historicalSelect) { _ in
                            if !pastSelect && !historicalSelect {
                                historicalSelect=true
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

