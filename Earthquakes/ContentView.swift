//
//  ContentView.swift
//  Earthquakes
//
//  Created by [REDACTED] on 17/12/2024.
//

import SwiftUI
import SceneKit
import CoreLocation
import WebKit


struct Earthquake: Identifiable, Equatable {
    let id: String
    let mag: Double
    let loc: String
    let lat: Double?
    let lon: Double?
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
        Earthquake(id: "1", mag: 9.5, loc: "Chile, Valdivia", lat: -39.8138, lon: -73.2404, url: "", time: "May 22, 1960"),
        Earthquake(id: "2", mag: 9.2, loc: "United States, Alaska", lat: 61.3706, lon: -152.4044, url: "", time: "March 27, 1964"),
        Earthquake(id: "3", mag: 9.0, loc: "USSR, Kamchatka", lat: 53.1018, lon: 158.6431, url: "", time: "November 5, 1952"),
        Earthquake(id: "4", mag: 8.8, loc: "Ecuador – Colombia", lat: -0.1754, lon: -78.4678, url: "", time: "January 31, 1906"),
        Earthquake(id: "5", mag: 8.7, loc: "United States, Alaska", lat: 61.3706, lon: -152.4044, url: "", time: "February 4, 1965"),
        Earthquake(id: "6", mag: 8.7, loc: "India, Assam – China, Tibet", lat: 27.6074, lon: 91.9784, url: "", time: "August 15, 1950"),
        Earthquake(id: "7", mag: 8.6, loc: "United States, Alaska", lat: 61.3706, lon: -152.4044, url: "", time: "March 9, 1957"),
        Earthquake(id: "8", mag: 8.6, loc: "United States, Aleutian Island", lat: 52.6644, lon: -175.1164, url: "", time: "April 1, 1946"),
        Earthquake(id: "9", mag: 8.5, loc: "USSR, Kuril Islands", lat: 44.0214, lon: 153.6819, url: "", time: "October 13, 1963"),
        Earthquake(id: "10", mag: 8.5, loc: "Indonesia, Banda Sea", lat: -6.7836, lon: 129.8606, url: "", time: "February 1, 1938"),
        Earthquake(id: "11", mag: 8.5, loc: "Chile, Atacama", lat: -27.0345, lon: -70.4368, url: "", time: "November 10, 1922"),
        Earthquake(id: "12", mag: 8.5, loc: "Western Samoa", lat: -13.7590, lon: -172.1046, url: "", time: "June 25, 1917"),
        Earthquake(id: "13", mag: 9.2, loc: "Indonesia, Sumatra, Indian Ocean", lat: 3.3166, lon: 95.8558, url: "", time: "December 26, 2004"),
        Earthquake(id: "14", mag: 9.0, loc: "Japan, Tōhoku, Pacific Ocean", lat: 38.3228, lon: 142.3734, url: "", time: "March 11, 2011"),
        Earthquake(id: "15", mag: 8.8, loc: "Chile, Maule", lat: -35.7010, lon: -71.7984, url: "", time: "February 27, 2010"),
        Earthquake(id: "16", mag: 8.6, loc: "Indonesia, Sumatra", lat: 1.1603, lon: 99.8789, url: "", time: "March 28, 2005"),
        Earthquake(id: "17", mag: 8.6, loc: "Indonesia, Sumatra", lat: 1.1603, lon: 99.8789, url: "", time: "April 11, 2012"),
        Earthquake(id: "18", mag: 8.5, loc: "Indonesia, Sumatra", lat: 1.1603, lon: 99.8789, url: "", time: "September 12, 2007")
    ]
    @State private var HistoricalSelect: Bool = true
    @State private var PastDaySelect: Bool = true
//    @State private var MBEVisible: Bool = true
    
    var body: some View {
        
        NavigationSplitView {
            SidebarView(earthquakes: $earthquakes, historicEarthquakes: $historicEarthquakes, PastDaySelect: $PastDaySelect, HistoricalSelect: $HistoricalSelect)
        } detail: {
            EarthView(earthquakes: $earthquakes, historicEarthquakes: $historicEarthquakes, PastDaySelect: $PastDaySelect, HistoricalSelect: $HistoricalSelect)
        }
        .toolbar {
            ToolbarItem(id:"refresh", placement: .automatic) {
                HStack {
                    Button(action:  EarthView(earthquakes: $earthquakes, historicEarthquakes: $historicEarthquakes, PastDaySelect: $PastDaySelect, HistoricalSelect: $HistoricalSelect).fetchEarthquakeData) {
                        Image(systemName: "arrow.clockwise")
                            .imageScale(.large)
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(.white)
                            .padding()
                    }
                    Spacer()
                }
            }
            ToolbarItem(id:"settings", placement: .automatic) {
                Button(action: {
                    let settingsPanel = createSettingsPanel(HistoricalSelect: $HistoricalSelect, PastDaySelect: $PastDaySelect)
                    settingsPanel?.makeKeyAndOrderFront(nil)
                }) {
                    Image(systemName: "gear")
                        .imageScale(.large)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.white)
                        .padding()
                }
            }
        }
        
        
//        MenuBarExtra("Earthquakes", isInserted: $MBEVisible) {
//            Text("Earthquakes today: \(earthquakes.count)")
//                .padding()
//            Text("Earthquakes near you today: \(earthquakesNearLoc)")
//            Divider()
//            Button(action: {
//                let settingsPanel = createSettingsPanel(HistoricalSelect: $HistoricalSelect, PastDaySelect: $PastDaySelect)
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
    
    private func createSettingsPanel(HistoricalSelect: Binding<Bool>, PastDaySelect: Binding<Bool>) -> NSPanel? {
        if settingsPanel == nil {
            let panel = NSPanel(contentRect: NSRect(x:0,y:0,width:300,height:450), styleMask: [.titled, .closable, .utilityWindow], backing: .buffered, defer: false)
            
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.hidesOnDeactivate = true
            panel.isReleasedWhenClosed = false
            panel.title = "Settings"
            panel.contentView = NSHostingView(rootView: SettingsView(PastDaySelect: $PastDaySelect, HistoricalSelect: $HistoricalSelect))//, MBEVisible: $MBEVisible))
            
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
    @Binding var PastDaySelect: Bool
    @Binding var HistoricalSelect: Bool
    @State private var selectedEarthquake: Earthquake? = nil
    @State private var showPopover: Bool=false

    var body: some View {
        List {
            if PastDaySelect {
                Section("Past 24h (\(earthquakes.count))") {
                    ForEach(earthquakes, id: \.id) { e in
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
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("ID: ").foregroundStyle(.secondary)+Text(se.id).foregroundStyle(.primary).bold()
                                        .font(.headline)
                                        .bold()
                                        //.padding(.bottom, 5)
                                    Text("Magnitude: ").foregroundStyle(.secondary)+Text("\(se.mag, specifier: "%.1f")").foregroundStyle(.primary).bold()
                                    Text("Location: ").foregroundStyle(.secondary)+Text(se.loc).foregroundStyle(.primary).bold()
                                    Text("UTC Time: ").foregroundStyle(.secondary)+Text(se.time).foregroundStyle(.primary).bold()
                                    Link("More info", destination: URL(string: se.url)!)
                                        .underline()
                                        .onTapGesture {
                                            openLink(url: se.url)
                                        }
                                }
                                .padding()
                                .frame(width: 200)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            if HistoricalSelect {
                Section("Historic Earthquakes") {
                    ForEach(historicEarthquakes, id: \.id) { e in
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
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Earthquake: ").foregroundStyle(.secondary)+Text(se.loc).foregroundStyle(.primary).bold()
                                        .font(.headline)
                                        .bold()
                                        //.padding(.bottom, 5)
                                    Text("Magnitude: ").foregroundStyle(.secondary)+Text("\(se.mag, specifier: "%.1f")").foregroundStyle(.primary).bold()
                                    Text("Date: ").foregroundStyle(.secondary)+Text(se.time).foregroundStyle(.primary).bold()
                                }
                                .padding()
                                .frame(width: 200)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Earthquakes")
    }
    
    private func openLink(url: String) {
        guard let url = URL(string: url) else {return}
        
        let config = """
        tell application "Safari"
            make new document with properties {URL:"\(url.absoluteString)"}
            activate
        end tell
        """
        
        let aS = NSAppleScript(source: config)
        aS?.executeAndReturnError(nil)
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
}

struct EarthView: View {
    @State private var scene = SCNScene()
    @Binding var earthquakes: [Earthquake]
    @Binding var historicEarthquakes: [Earthquake]
    @Binding var PastDaySelect: Bool
    @Binding var HistoricalSelect: Bool
    private let earthquakeURL = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson")!
    
    
    var body: some View {
        VStack {
            SceneView (
                scene: scene,
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            setupScene()
            fetchEarthquakeData()
        }
        .onChange(of: PastDaySelect, initial: true, {
            scene.rootNode.childNodes.filter {
                $0.name?.starts(with: "EPD") ?? false
            }.forEach {
                $0.removeFromParentNode()
                print("Removing pin \(String($0.name!))")
            }
        })
        .onChange(of: HistoricalSelect, initial: true, {
            scene.rootNode.childNodes.filter {
                $0.name?.starts(with: "EH") ?? false
            }.forEach {
                $0.removeFromParentNode()
                print("Removing pin \(String($0.name!))")
            }
        })
        .onChange(of: PastDaySelect, initial: false, {
            fetchEarthquakeData()
        })
        .onChange(of: HistoricalSelect, initial: false, {
            fetchEarthquakeData()
        })
    }
    
    func setupScene() {
        scene.background.contents = "black.stars"
        
        let earthNode = createEarthNode()
        scene.rootNode.addChildNode(earthNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light?.type = .omni
//        lightNode.position = SCNVector3(x: 0, y: 10, z: 200)
//        scene.rootNode.addChildNode(lightNode)
//
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light?.type = .ambient
//        ambientLightNode.light?.color = Color.gray
//        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func fetchEarthquakeData() {
        URLSession.shared.dataTask(with: earthquakeURL) { data, _, error in
            guard let data=data, error==nil else { return }
            print("fetched data")
            do {
                if let geoJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any], let features = geoJSON["features"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        print("updating")
                        self.updateEarquakeList(features)
                        let select = PastDaySelect && !HistoricalSelect ? 0 : HistoricalSelect && !PastDaySelect ? 1 : 2
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
            if let properties = feature["properties"] as? [String: Any], let mag=properties["mag"] as? Double, let place=properties["place"] as? String, let url=properties["url"] as? String, let eid=feature["id"] as? String, let time=properties["time"] as? Int64 {
                nEarthquakes.append(Earthquake(id: eid, mag: mag, loc: place, lat:nil, lon:nil, url: url, time: String(format: "%02d:%02d:%02d", (time/1000/3600)%24, (time/1000/60)%60, (time/1000)%60)))
            }
        }
        self.earthquakes = nEarthquakes
        //print(nEarthquakes)
    }
    
    func updateEarthquakePins(_ features: [[String: Any]], _ select: Int) { // 0: Past day, 1: Historical, 2: both
        scene.rootNode.childNodes.filter {
            $0.name?.starts(with: "E") ?? false
        }.forEach {
            $0.removeFromParentNode()
            //print("Removing pin \(String($0.name!))")
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
//        scene.rootNode.childNodes.filter {
//            $0.name?.starts(with: select==1 ? "EPD" : select==0 ? "EH" : "None") ?? false
//        }.forEach {
//            $0.removeFromParentNode()
//            print("Removing pin \(String($0.name!))")
//        }
    }
    
    func addEarthquakePin(lat:Double, lon:Double, mag:Double, id:String, first:String) {
        let pinNode = createPinNode(color: mag>=7 ? NSColor(red: 117/255.0, green: 20/255.0, blue: 12/255.0, alpha: 1) : mag>=6 ? NSColor(calibratedRed: 249/255.0, green: 127/255.0, blue: 73/255.0, alpha: 1) : mag>=5 ? NSColor(calibratedRed: 255/255.0, green: 255/255.0, blue: 84/255.0, alpha: 1) : mag>=4 ? NSColor(calibratedRed: 191/255.0, green: 253/255.0, blue: 91/255.0, alpha: 1) : mag>=3 ? NSColor(calibratedRed: 175/255.0, green: 249/255.0, blue: 162/255.0, alpha: 1) : mag>=2 ? NSColor(calibratedRed: 188/255.0, green: 236/255.0, blue: 237/255.0, alpha: 1) : NSColor(calibratedRed: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1))
        pinNode.position = convertCoordinatesTo3D(lat: lat, lon: lon)
        pinNode.name = "E\(first)EarthquakePin_\(id)"
        //print("Adding pin \(String(pinNode.name!))")
        
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
    @Binding var PastDaySelect: Bool
    @Binding var HistoricalSelect: Bool
//    @Binding var MBEVisible: Bool
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.headline)
                .bold()
                .padding(.top, 10)
            HStack {
                Text("Show: ")
                    .padding()
                Toggle("Past 24h", isOn: $PastDaySelect)
                    .toggleStyle(.checkbox)
                    .onChange(of: PastDaySelect) {
                        if !HistoricalSelect && !PastDaySelect {
                            PastDaySelect=true
                        }
                    }
                Toggle("Historical", isOn: $HistoricalSelect)
                    .toggleStyle(.checkbox)
                    .onChange(of: HistoricalSelect) {
                        if !PastDaySelect && !HistoricalSelect {
                            HistoricalSelect=true
                        }
                    }
            }.padding()
//            Toggle("Show Menu Bar Item", isOn: $MBEVisible)
//                .toggleStyle(.switch)
//                .padding()
        }
    }
}

#Preview {
    ContentView()
}
