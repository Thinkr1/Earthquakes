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
    
//    var coordinate: CLLocationCoordinate2D? {
//        guard let lat = lat, let lon = lon else { return nil }
//        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
//    }
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
    @AppStorage("historicalSelect") private var historicalSelect: Bool = true
    @AppStorage("pastSelect") private var pastSelect: Bool = true
    @AppStorage("dataRange") private var dataRange: Int = 0 // 0: past 24h, 1: past week, 2: past month
    @AppStorage("resultsPerPage") private var resultsPerPage: Int = 25
    @State private var selectedEarthquakeID: String? = nil
    @State private var isLoading: Bool = false
    @State private var showLargeDataWarning: Bool = false
    @State private var searchText: String = ""
    @State private var searchIndex: [String: Set<String>] = [:] // word: earthquake IDs
    @State private var searchDebounceTask: Task<Void, Never>?

    private var searchResults: [Earthquake] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return [] }
        
        let words = query.components(separatedBy: " ").filter { !$0.isEmpty }
        guard !words.isEmpty else { return [] }
        
        var matchingIDs = Set<String>()
        for word in words {
            for (indexWord, ids) in searchIndex where indexWord.hasPrefix(word) {
                matchingIDs.formUnion(ids)
            }
        }
        
        let all = earthquakes + historicEarthquakes
        return all.filter { matchingIDs.contains($0.id) }
            .sorted { $0.time > $1.time }
//            .prefix(resultsPerPage)
            .map { $0 }
    }

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
                                    Task { @MainActor in
                                        withAnimation {
                                            isLoading = true
                                        }
                                        await fetchEarthquakeData()
                                        withAnimation {
                                            isLoading = false
                                        }
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
                                Task { @MainActor in
                                    withAnimation {
                                        isLoading = true
                                    }
                                    await fetchEarthquakeData()
                                    withAnimation {
                                        isLoading = false
                                    }
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
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search earthquakes")
            .searchSuggestions {
                if !searchResults.isEmpty {
                    ForEach(searchResults.prefix(resultsPerPage), id: \.id) { e in
                        Button(action: {
                            handleSearchSelection(e)
                        }) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(
                                        red: 0.0 + min(max((e.mag - 2.0)/5.0, 0), 1) * 0.46,
                                        green: 1.0 - min(max((e.mag - 2.0)/5.0, 0), 1) * 0.6,
                                        blue: 0.0 + min(max((e.mag - 2.0)/5.0, 0), 1) * 0.46
                                    ))
                                    .frame(width: 10, height: 10)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(e.mag, specifier: "%.1f") • \(e.place)")
                                        .font(.subheadline)
                                        .bold()
                                    Text(e.loc)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    HStack(alignment: .center) {
                        Spacer()
                        Text("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s") found (showing \(searchResults.prefix(resultsPerPage).count))").font(.caption).foregroundStyle(.secondary).padding()
                        Spacer()
                    }
                } else if !searchText.isEmpty {
                    Text("No results for \"\(searchText)\"")
                        .foregroundStyle(.secondary)
                }
            }
            .onSubmit(of: .search) {
                if let first = searchResults.first {
                    handleSearchSelection(first)
//                    let id = first.id
//                    if earthquakes.contains(where: { $0.id == id }) {
//                        pastSelect = true
//                    }
//                    if historicEarthquakes.contains(where: { $0.id == id }) {
//                        historicalSelect = true
//                    }
//                    selectedEarthquakeID = id
//                    searchText = ""
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
                
                buildSearchIndex()
            }
            .onChange(of: earthquakes, initial: false) { _,_ in
                buildSearchIndex()
            }
            .onChange(of: historicEarthquakes, initial: false) { _,_ in
                buildSearchIndex()
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
    
    @MainActor private func fetchEarthquakeData() async {
        let urlString: String
        switch dataRange {
        case 0:
            urlString = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
        case 1:
            urlString = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson"
        default:
            urlString = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson"
        }

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let any = try JSONSerialization.jsonObject(with: data)
            guard let geoJSON = any as? [String: Any],
                  let features = geoJSON["features"] as? [[String: Any]] else {
                return
            }

            var newQuakes: [Earthquake] = []
            newQuakes.reserveCapacity(features.count)

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
                        print("failed to apply regex, keeping capitalised state name")
                    }

                    newQuakes.append(Earthquake(
                        id: eid,
                        mag: mag,
                        MMI: MMI,
                        sig: sig,
                        loc: place,
                        place: state,
                        lat: coords.count > 1 ? coords[1] : nil,
                        lon: coords.first,
                        depth: coords.count > 2 ? coords[2] : 0,
                        url: url,
                        time: formattedTime
                    ))
                }
            }

            self.earthquakes = newQuakes
        } catch {
            print("fetching error")
        }
    }
    
    private func buildSearchIndex() {
        Task.detached(priority: .utility) {
            let all = await MainActor.run { [earthquakes, historicEarthquakes] in earthquakes + historicEarthquakes }
            var index: [String: Set<String>] = [:]
            
            for e in all {
                let text = "\(e.loc) \(e.place) \(e.id)".lowercased()
                let words = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
                    .filter { $0.count >= 2 }
                
                for w in words {
                    index[w, default: []].insert(e.id)
                }
            }
            
            await MainActor.run { [index] in
                self.searchIndex = index
            }
        }
    }
    
    private func handleSearchSelection(_ e: Earthquake) {
        print("Search: Selected earthquake ID: \(e.id)")
        
        let inPast = earthquakes.contains(where: { $0.id == e.id })
        let inHistoric = historicEarthquakes.contains(where: { $0.id == e.id })
        
        print("Search: Found in past: \(inPast), historic: \(inHistoric)")
        
        if inPast {
            pastSelect = true
            print("Search: Enabled pastSelect")
        }
        if inHistoric {
            historicalSelect = true
            print("Search: Enabled historicalSelect")
        }
        
        searchText = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            print("Search: Setting selectedEarthquakeID to \(e.id)")
            selectedEarthquakeID = e.id
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
            panel.contentView = NSHostingView(rootView: SettingsView())//, MBEVisible: $MBEVisible))
            
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
