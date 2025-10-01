//
//  EarthView.swift
//  Earthquakes
//
//  Created by Pierre-Louis ML on 29/09/2025.
//

import SwiftUI
import SceneKit

struct EarthView: View {
    @State private var scene = SCNScene()
    //    @State private var selectedEarthquake: Earthquake?
    //    @State private var showPopover: Bool = false
    //    @State private var popoverAnchor: CGPoint = .zero
    @State private var debounceTimer: Timer?
    @State private var isCameraAnimating: Bool = false
    @State private var sceneView: SCNView?
    @Binding var earthquakes: [Earthquake]
    @Binding var historicEarthquakes: [Earthquake]
    @Binding var pastSelect: Bool
    @Binding var historicalSelect: Bool
    @Binding var dataRange: Int
    @Binding var selectedEarthquakeID: String?
    @Binding var isLoading: Bool
    
    private static let pinGeo: SCNSphere = {
        let sphere = SCNSphere(radius: 0.012)
        sphere.segmentCount = 8
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
            ClickableSceneView(scene: scene, sceneViewRef: $sceneView) { id in
                selectedEarthquakeID = id
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .onChange(of: selectedEarthquakeID, initial: false) { oldValue, newValue in
            if newValue == nil && isCameraAnimating {
                print("EarthView: Ignoring selection clear during camera animation")
                return
            }
            guard let id = newValue else {
                print("EarthView: selectedEarthquakeID cleared")
                return
            }
            
            print("EarthView: selectedEarthquakeID changed to: \(id)")
            
            let pdPinName = "EPDEarthquakePin_\(id)"
            let hPinName = "EHEarthquakePin_\(id)"
            
            func attemptAnimation(retryCount: Int = 0) {
                if let _ = scene.rootNode.childNode(withName: pdPinName, recursively: true) {
                    print("EarthView: Found past earthquake pin: \(pdPinName)")
                    animateCameraToPin(id: pdPinName)
                } else if let _ = scene.rootNode.childNode(withName: hPinName, recursively: true) {
                    print("EarthView: Found historic earthquake pin: \(hPinName)")
                    animateCameraToPin(id: hPinName)
                } else if retryCount < 20 { // retry for up to 2s
                    print("EarthView: Pin not found, retrying... (\(retryCount + 1)/20)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        attemptAnimation(retryCount: retryCount + 1)
                    }
                } else {
                    print("EarthView: Pin not found after retries for ID: \(id)")
                    print("EarthView: Available pins: \(scene.rootNode.childNodes.filter { $0.name?.starts(with: "E") ?? false }.map { $0.name ?? "unnamed" })")
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                attemptAnimation()
            }
        }
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
    
    func animateCameraToPin(id: String) {
        guard !isCameraAnimating else {
            print("Camera animation already in progress, ignoring")
            return
        }
        
        guard let pinNode = scene.rootNode.childNode(withName: id, recursively: true) else {
            print("Pin not found: \(id)")
            return
        }
        
        guard let camNode = scene.rootNode.childNodes.first(where: {$0.camera != nil}) else {
            print("Camera not found")
            return
        }
        
        let pinPos = pinNode.position
        let dir = SCNVector3(pinPos.x-0, pinPos.y-0,pinPos.z-0) // dir from Earth centre to pin
        let length = sqrt(dir.x*dir.x + dir.y*dir.y + dir.z*dir.z)
        let camDist: CGFloat = 3.0
        let newCamPos = SCNVector3(dir.x/length * camDist, dir.y/length * camDist, dir.z/length * camDist)
        
        isCameraAnimating = true
        
        let wasAllowingCameraControl = sceneView?.allowsCameraControl ?? false
        sceneView?.allowsCameraControl = false
        
        camNode.constraints = []
        
        if let view = sceneView {
            view.pointOfView = camNode
        }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.7
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        SCNTransaction.completionBlock = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if wasAllowingCameraControl {
                    self.sceneView?.allowsCameraControl = true
                }
                self.isCameraAnimating = false
                print("Camera animation completed")
            }
        }
        camNode.position = newCamPos
        let lookConstraint = SCNLookAtConstraint(target: scene.rootNode)
        lookConstraint.isGimbalLockEnabled = true
        camNode.constraints = [lookConstraint]
//        camNode.look(at: SCNVector3(0, 0, 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        SCNTransaction.commit()
        
        print("Camera animated to pos: \(newCamPos)")
    }
    
    func fetchEarthquakeData() {
        isLoading = true
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            Task { await self.fetchEarthquakeDataDebounce() }
        }
    }
    
    func fetchEarthquakeDataDebounce() async {
        await MainActor.run {
            self.earthquakes.removeAll()
        }
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
    
    private func processFeatChunk(_ features: [[String: Any]]) async -> [Earthquake] {
        await Task.detached(priority: .userInitiated) {
            var earthquakes: [Earthquake] = []
            earthquakes.reserveCapacity(features.count)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let stateRegex = /of (.*)/
            
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
                    
                    let formattedTime = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(time / 1000)))
                    
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
        }.value
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
        let existingPins = Set(scene.rootNode.childNodes
            .filter { $0.name?.starts(with: "E") ?? false }
            .compactMap { $0.name })
        
        var desiredPins = Set<String>()
        var pinsToAdd: [SCNNode] = []
        
        if select == 0 || select == 2 {
            for feature in features {
                if let geo = feature["geometry"] as? [String: Any],
                   let coord = geo["coordinates"] as? [Double], coord.count >= 2,
                   let properties = feature["properties"] as? [String: Any],
                   let mag = properties["mag"] as? Double,
                   let idStr = feature["id"] as? String {
                    
                    let pinName = "EPDEarthquakePin_\(idStr)"
                    desiredPins.insert(pinName)
                    
                    if !existingPins.contains(pinName) {
                        let pinNode = createPinNode(
                            color: getMagColor(mag),
                            position: convertCoordinatesTo3D(lat: coord[1], lon: coord[0]),
                            id: pinName
                        )
                        pinsToAdd.append(pinNode)
                    }
                }
            }
        }
        
        if select == 1 || select == 2 {
            for e in historicEarthquakes {
                if let lat = e.lat, let lon = e.lon {
                    let pinName = "EHEarthquakePin_\(e.id)"
                    desiredPins.insert(pinName)
                    
                    if !existingPins.contains(pinName) {
                        let node = createPinNode(
                            color: getMagColor(e.mag),
                            position: convertCoordinatesTo3D(lat: lat, lon: lon),
                            id: pinName
                        )
                        pinsToAdd.append(node)
                    }
                }
            }
        }
        
        let pinsToRemove = existingPins.subtracting(desiredPins)
        if !pinsToRemove.isEmpty {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0
            scene.rootNode.childNodes
                .filter { pinsToRemove.contains($0.name ?? "") }
                .forEach { $0.removeFromParentNode() }
            SCNTransaction.commit()
        }
        
        if !pinsToAdd.isEmpty {
            let batchSize = 100
            for batch in pinsToAdd.chunked(batchSize) {
                DispatchQueue.main.async {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0
                    batch.forEach { self.scene.rootNode.addChildNode($0) }
                    SCNTransaction.commit()
                }
            }
        }
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
            node.geometry?.firstMaterial?.isDoubleSided = true
        } else {
            let material = SCNMaterial()
            material.diffuse.contents = color
            node.geometry?.materials = [material]
            node.geometry?.firstMaterial?.isDoubleSided = true
        }
        
        node.position = position
        node.name = id
        node.categoryBitMask = 0x2 // mark as "pin" for hit-testing
        
        print("Created pin node: \(id) at position: \(position)")
        
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

struct ClickableSceneView: NSViewRepresentable {
    let scene: SCNScene
    @Binding var sceneViewRef: SCNView?
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
        scnView.autoenablesDefaultLighting = false
        scnView.backgroundColor = .clear
        scnView.isPlaying = true
        scnView.delegate = context.coordinator
        scnView.coordinator = context.coordinator
        
        scnView.rendersContinuously = false
        scnView.antialiasingMode = .none
        
        let light = SCNLight()
        light.type = .ambient
        light.intensity = 1000
        let lightNode = SCNNode()
        lightNode.light = light
        scene.rootNode.addChildNode(lightNode)
        
        context.coordinator.view = scnView
        DispatchQueue.main.async {
            sceneViewRef = scnView
        }
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
                DispatchQueue.main.async {
                    self.onNodeClick(String(idPart))
                }
            } else {
                print("ClickableSceneView: could not extract ID from name: \(name)")
            }
        }
    }
}
