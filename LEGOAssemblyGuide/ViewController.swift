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
    var nodes = [SCNNode]()
    var animation = SCNAction()
    var currentActionIndex = 0
    var initialDragPoint = CGPoint()
    var shapeNode = SCNScene(named: "art.scnassets/LEGO.scn")!.rootNode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions.insert(SCNDebugOptions.showWireframe)
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Recognize one finger tap
        let oneTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(oneTapGestureFired(_ :)))
        oneTapRecognizer.numberOfTapsRequired = 1
        oneTapRecognizer.numberOfTouchesRequired = 1
        
        // Recognize two finger tap
        let twoTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(twoTapGestureFired(_ :)))
        twoTapRecognizer.numberOfTapsRequired = 1
        twoTapRecognizer.numberOfTouchesRequired = 2
        
        // Recognize long press
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureFired(_ :)))
        longPressRecognizer.numberOfTouchesRequired = 1
        longPressRecognizer.minimumPressDuration = 1
        
        sceneView.addGestureRecognizer(oneTapRecognizer)
        sceneView.addGestureRecognizer(twoTapRecognizer)
        sceneView.addGestureRecognizer(longPressRecognizer)
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
        
        if #available(iOS 13.0, *) {
            //configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
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
                
                self.shapeNode.position = SCNVector3(x: 0, y: 0, z: -10.1)
                self.shapeNode.eulerAngles.y = -.pi / 2
                
                for firstIndex in "ab" {
                    for secondIndex in "abcdefghijklmnopqrstuvwxyz" {
                        let index = String(firstIndex) + String(secondIndex)
                        self.nodes.append(self.shapeNode.childNode(withName: index, recursively: true)!)
                    }
                }
                
                let level1 = self.shapeNode.childNode(withName: "L1", recursively: true)
                let level2 = self.shapeNode.childNode(withName: "L2", recursively: true)
                let level3 = self.shapeNode.childNode(withName: "L3", recursively: true)
                let ng = self.shapeNode.childNode(withName: "NG", recursively: true)
                let nc = self.shapeNode.childNode(withName: "NC", recursively: true)
                let bb = self.shapeNode.childNode(withName: "BB", recursively: true)
                let le = self.shapeNode.childNode(withName: "LE", recursively: true)
                let lb = self.shapeNode.childNode(withName: "LB", recursively: true)
                
                let levels = [level1, level2, level3]
                let buildings = [ng, nc, bb, le, lb]
                
                for level in levels {
                    for node in level!.childNodes.shuffled() {
                        node.isHidden = true
                    }
                }
                
                for building in buildings {
                    for node in building!.childNodes.shuffled() {
                        node.isHidden = true
                    }
                }
                
                let duration = 0.5
                
                let fadeOut = SCNAction.fadeOpacity(by: -2, duration: duration)
                let fadeIn = SCNAction.fadeOpacity(by: 1, duration: duration)
                self.animation = SCNAction.repeatForever(SCNAction.sequence([fadeOut, fadeIn]))
                
                self.nodes.first?.isHidden = false
                self.nodes.first?.runAction(self.animation)
                
                node.addChildNode(self.shapeNode)
            }
        }
        return node
        
    }
    
    func nextAction(_ node: SCNNode) {
        node.removeAllActions()
        node.opacity = 0.01
        //node.isHidden = true
        self.currentActionIndex += 1
        if (self.currentActionIndex < self.nodes.count) {
            self.nodes[self.currentActionIndex].isHidden = false
            self.nodes[self.currentActionIndex].runAction(self.animation)
        } else {
            self.shapeNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)))
        }
    }
    
    func prevAction(_ node: SCNNode) {
        node.removeAllActions()
        node.opacity = 1
        node.isHidden = true
        self.currentActionIndex -= 1
        self.nodes[self.currentActionIndex].opacity = 1
        self.nodes[self.currentActionIndex].runAction(self.animation)
    }
    
    @objc func oneTapGestureFired(_ gesture: UITapGestureRecognizer) {
        if (self.currentActionIndex < self.nodes.count) {
            self.nextAction(nodes[self.currentActionIndex])
            print(self.currentActionIndex)
        } else {
            print("No more steps!")
        }
    }
    
    @objc func twoTapGestureFired(_ gesture: UITapGestureRecognizer) {
        if (self.currentActionIndex == self.nodes.count) {
            print("Assembly finished!")
        } else if (self.currentActionIndex > 0) {
            self.prevAction(nodes[self.currentActionIndex])
            print(self.currentActionIndex)
        } else {
            print("No more previous steps!")
        }
    }
    
    @objc func longPressGestureFired(_ gesture: UILongPressGestureRecognizer) {
        if (gesture.state == .began) {
            print("Action jump enabled!")
            guard let view = gesture.view else {return}
            self.initialDragPoint = gesture.location(in: view.superview)
        } else if (gesture.state == .changed) {
            guard let view = gesture.view else {return}
            let point = gesture.location(in: view.superview)
            let dragDistanceX = point.x - initialDragPoint.x
            print(dragDistanceX)
            
        } else if (gesture.state == .ended) {
            print("Action jump disabled!")
        }
    }
    
}
