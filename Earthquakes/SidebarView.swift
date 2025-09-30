//
//  SidebarView.swift
//  Earthquakes
//
//  Created by Pierre-Louis ML on 29/09/2025.
//

import SwiftUI

struct SidebarView: View {
    @Binding var earthquakes: [Earthquake]
    @Binding var historicEarthquakes: [Earthquake]
    @Binding var pastSelect: Bool
    @Binding var historicalSelect: Bool
    @Binding var dataRange: Int
    @Binding var selectedEarthquakeID: String?
    @State private var idIndex: [String: Earthquake] = [:]
    @State private var indexRebuildWorkItem: DispatchWorkItem?
    
    var body: some View {
        ScrollViewReader { proxy in
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
            .onAppear {
                scheduleIndexRebuild()
            }
            .onChange(of: earthquakes, initial: false) {_,_ in
                scheduleIndexRebuild()
            }
            .onChange(of: historicEarthquakes, initial: false) {_,_ in
                scheduleIndexRebuild()
            }
            .onChange(of: selectedEarthquakeID, initial: false) { oldValue, newValue in
                print("SidebarView: selectedEarthquakeID changed to: \(newValue ?? "nil")")
                guard let id = newValue else {
                    return
                }
                
                if let match = idIndex[id] ?? earthquakes.first(where: { $0.id == id }) ?? historicEarthquakes.first(where: { $0.id == id }) {
                    print("SidebarView: Found matching earthquake: \(match.id)")
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                } else {
                    print("SidebarView: No matching earthquake found for ID: \(id)")
                }
            }
        }
    }
    
    private func scheduleIndexRebuild() {
        indexRebuildWorkItem?.cancel()
        let work = DispatchWorkItem { [earthquakes, historicEarthquakes] in
            let combined = earthquakes+historicEarthquakes
            var dict = [String: Earthquake](minimumCapacity: combined.count)
            for e in combined { dict[e.id]=e }
            DispatchQueue.main.async {
                self.idIndex = dict
            }
        }
        
        indexRebuildWorkItem = work
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now()+0.2, execute: work)
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
//            selectedEarthquake = e
//            showPopover = true
            selectedEarthquakeID = e.id
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
        }.id(e.id)
            .popover(isPresented: Binding(get: {
                selectedEarthquakeID == e.id
            }, set: { newVal in
                if !newVal {
                    if selectedEarthquakeID == e.id {
                        selectedEarthquakeID = nil
                    }
//                    showPopover = false
                }
            })) {
                historicalSectionRowPopoverContent(/*selectedEarthquake ?? */e)
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
//            selectedEarthquake = e
//            showPopover = true
            selectedEarthquakeID = e.id
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
        }.id(e.id)
            .popover(isPresented: Binding(get: {
                selectedEarthquakeID == e.id
            }, set: { newVal in
                if !newVal {
                    if selectedEarthquakeID == e.id {
                        selectedEarthquakeID = nil
                    }
//                    showPopover = false
                }
            })) {
                pastDaySectionRowPopoverContent(/*selectedEarthquake ?? */e)
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
