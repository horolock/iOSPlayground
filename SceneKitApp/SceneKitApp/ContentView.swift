//
//  ContentView.swift
//  SceneKitApp
//
//  Created by HoJoonKim on 11/8/25.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    var scene: SCNScene {
        let scene = SCNScene()
        let sphereGeometry = SCNSphere(radius: 1.0)
        
        // Make Sphere to Red
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.red
        sphereGeometry.materials = [sphereMaterial]
        
        let sphereNode = SCNNode(geometry: sphereGeometry)
        
        scene.rootNode.addChildNode(sphereNode)
        
        // MARK: - Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        scene.rootNode.addChildNode(cameraNode)
        
        // MARK: - Light
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        return scene
    }
    
    var body: some View {
        SceneView(scene: scene, options: [
            .allowsCameraControl,
            .autoenablesDefaultLighting
        ])
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
