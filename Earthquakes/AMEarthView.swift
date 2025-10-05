//
//  AMEarthView.swift
//  Earthquakes
//
//  Created by Pierre-Louis ML on 02/10/2025.
//

import SwiftUI
import MapKit

struct AMEarthView: View {
    @Binding var earthquakes: [Earthquake]
    @Binding var historicEarthquakes: [Earthquake]
    @Binding var pastSelect: Bool
    @Binding var historicalSelect: Bool
    @Binding var selectedEarthquakeID: String?
    @Binding var dataRange: Int
    @Binding var isLoading: Bool
    
    var onFetchData: () async -> Void
    
    @State private var camPos: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 20, longitude: 0),
            distance: 20_000_000, // full view
            heading: 0,
            pitch: 0
        )
    )
    @State private var hasLoadedInitData = false
    
    private var visibleEarthquakes: [Earthquake] {
        var res: [Earthquake] = []
        if pastSelect {
            res.append(contentsOf: earthquakes)
        }
        if historicalSelect {
            res.append(contentsOf: historicEarthquakes)
        }
        return res.filter { $0.lat != nil && $0.lon != nil }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Map(position: $camPos, selection: $selectedEarthquakeID) {
                ForEach(visibleEarthquakes) { e in
                    if let lat = e.lat, let lon = e.lon {
                        Annotation(
                            e.place,
                            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        ) {
                            EarthquakeMarker(earthquake: e)
                        }
                        .tag(e.id)
                    }
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
            .onAppear {
                if !hasLoadedInitData {
                    hasLoadedInitData = true
                    Task {
                        await onFetchData()
                    }
                }
            }
            .onChange(of: selectedEarthquakeID) { _, newValue in
                guard let id = newValue,
                      let earthquake = visibleEarthquakes.first(where: { $0.id == id }),
                      let lat = earthquake.lat,
                      let lon = earthquake.lon else { return }
                
                withAnimation(.easeInOut(duration: 0.7)) {
                    camPos = .camera(
                        MapCamera(
                            centerCoordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                            distance: 750_000,
                            heading: 0,
                            pitch: 45
                        )
                    )
                }
            }
            .onChange(of: dataRange, initial: false) { _,_ in
                Task {
                    await onFetchData()
                }
            }
        }
    }
}

struct EarthquakeMarker: View {
    let earthquake: Earthquake
    
    private var markerColor: Color {
        let mag = earthquake.mag
        switch mag {
        case _ where mag >= 7:
            return Color(red: 117/255.0, green: 20/255.0, blue: 12/255.0)
        case _ where mag >= 6:
            return Color(red: 249/255.0, green: 127/255.0, blue: 73/255.0)
        case _ where mag >= 5:
            return Color(red: 255/255.0, green: 255/255.0, blue: 84/255.0)
        case _ where mag >= 4:
            return Color(red: 191/255.0, green: 253/255.0, blue: 91/255.0)
        case _ where mag >= 3:
            return Color(red: 175/255.0, green: 249/255.0, blue: 162/255.0)
        case _ where mag >= 2:
            return Color(red: 188/255.0, green: 236/255.0, blue: 237/255.0)
        default:
            return Color.white
        }
    }
    
    private var markerSize: CGFloat {
        let mag = earthquake.mag
        return CGFloat(max(8, min(mag * 3, 20)))
    }
    
    var body: some View {
        Circle()
            .fill(markerColor)
            .frame(width: markerSize, height: markerSize)
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 2)
            )
            .shadow(color: markerColor.opacity(0.6), radius: 4)
    }
}

#Preview {
    AMEarthView(
        earthquakes: .constant([
            Earthquake(id: "a", mag: 5.5, MMI: nil, sig: 500, loc: "test", place: "test", lat: 35.0, lon: -118.0, depth: 10, url: "", time: "01-01-01")
        ]),
        historicEarthquakes: .constant([]),
        pastSelect: .constant(true),
        historicalSelect: .constant(false),
        selectedEarthquakeID: .constant(nil),
        dataRange: .constant(0),
        isLoading: .constant(false),
        onFetchData: {}
    )
}
