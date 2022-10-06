//
//  ViewController.swift
//  LEGOAssemblyGuide
//
//  Created by Tianxiang Song on 10.05.22.
//  Copyright © 2022 Tianxiang Song. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var actions = [SCNAction]()
    var nodes = [SCNNode]()
    var currentActionIndex = 0
    let shapeNode = SCNScene(named: "art.scnassets/wheel.scn")!.rootNode.childNodes.first!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureFired(_ :)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        sceneView.addGestureRecognizer(gestureRecognizer)
        sceneView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: Bundle.main) else {
            print("No images available")
            return
        }

        configuration.trackingImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 1
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        DispatchQueue.main.async {
            if anchor is ARImageAnchor {
                
                self.shapeNode.position = SCNVector3Zero
                self.shapeNode.eulerAngles.y = -.pi / 2
                
                let ground = self.shapeNode.childNode(withName: "G", recursively: true)
                let level1 = self.shapeNode.childNode(withName: "L1", recursively: true)
                let level2 = self.shapeNode.childNode(withName: "L2", recursively: true)
                let level3 = self.shapeNode.childNode(withName: "L3", recursively: true)
                let level4 = self.shapeNode.childNode(withName: "L4", recursively: true)
                let leftOuter = self.shapeNode.childNode(withName: "LeftOuter", recursively: true)
                let rightOuter = self.shapeNode.childNode(withName: "RightOuter", recursively: true)
                let leftInner = self.shapeNode.childNode(withName: "LeftInner", recursively: true)
                let rightInner = self.shapeNode.childNode(withName: "RightInner", recursively: true)
                
                let duration = 2.0
                let distanceY = 2.0
                let distanceZ = 20.0
                
                let levels = [ground, level1, level2, level3, level4]
                let leftTires = [leftOuter, leftInner]
                let rightTires = [rightOuter, rightInner]
                
                for level in levels {
                    let initial = SCNAction.customAction(duration: 0) { (node, elapsedTime) in
                        level?.position.y = Float(distanceY)
                        level?.opacity = 0
                    }
                    let action = SCNAction.customAction(duration: duration) { (node, elapsedTime) in
                        level?.opacity = elapsedTime / duration
                        level?.position.y = Float(distanceY * (1 - elapsedTime/duration))
                    }
                    self.nodes.append(level!)
                    self.actions.append(SCNAction.repeatForever(SCNAction.group([initial, action])))
                    self.shapeNode.runAction(initial)
                }
                
                for leftTire in leftTires {
                    let initial = SCNAction.customAction(duration: 0) { (node, elapsedTime) in
                        leftTire?.position.z = Float(distanceZ)
                        leftTire?.opacity = 0
                    }
                    let action = SCNAction.customAction(duration: duration) { (node, elapsedTime) in
                        leftTire?.opacity = elapsedTime / duration
                        leftTire?.position.z = Float(distanceZ * (1 - elapsedTime/duration))
                    }
                    self.nodes.append(leftTire!)
                    self.actions.append(SCNAction.repeatForever(SCNAction.group([initial, action])))
                    self.shapeNode.runAction(initial)
                }
                
                for rightTire in rightTires {
                    let initial = SCNAction.customAction(duration: 0) { (node, elapsedTime) in
                        rightTire?.position.z = -Float(distanceZ)
                        rightTire?.opacity = 0
                    }
                    let action = SCNAction.customAction(duration: duration) { (node, elapsedTime) in
                        rightTire?.opacity = elapsedTime / duration
                        rightTire?.position.z = -Float(distanceZ * (1 - elapsedTime/duration))
                    }
                    self.nodes.append(rightTire!)
                    self.actions.append(SCNAction.repeatForever(SCNAction.group([initial, action])))
                    self.shapeNode.runAction(initial)
                }
                   
                //let sequence = SCNAction.sequence(actions)
                self.shapeNode.runAction(self.actions.first!, forKey: String(self.currentActionIndex))
                
                node.addChildNode(self.shapeNode)
            }
        }
        return node
        
    }
    
    func endAction(_ node: SCNNode) {
        self.shapeNode.removeAction(forKey: String(self.currentActionIndex))
        node.position = SCNVector3Zero
        node.opacity = 1
        self.currentActionIndex += 1
        if (self.currentActionIndex < self.actions.count) {
            self.shapeNode.runAction(self.actions[self.currentActionIndex], forKey: String(self.currentActionIndex))
        }
    }
    
    @objc func gestureFired(_ gesture: UITapGestureRecognizer) {
        if (self.currentActionIndex < self.actions.count) {
            self.endAction(nodes[self.currentActionIndex])
        }
    }
    
}
