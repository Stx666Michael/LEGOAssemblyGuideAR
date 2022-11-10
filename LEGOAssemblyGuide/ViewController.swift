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
    @IBOutlet weak var currentStep: UILabel!
    
    var nodes = [SCNNode]()
    var animation = SCNAction()
    var currentActionIndex = 0
    var lastActionShift = 0
    var initialPoint = CGPoint()
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
                
                for firstIndex in "abcde" {
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
                
                self.updateStepText()
                
                node.addChildNode(self.shapeNode)
            }
        }
        return node
    }
    
    func updateStepText() {
        if (self.currentActionIndex == self.nodes.count) {
            self.currentStep.text = "Construction done!"
        } else {
            self.currentStep.text = "Step: " + String(self.currentActionIndex+1) + " / " + String(self.nodes.count)
        }
    }
    
    func nextAction(_ node: SCNNode) {
        node.removeAllActions()
        node.opacity = 0.9
        self.currentActionIndex += 1
        
        if (self.currentActionIndex < self.nodes.count) {
            self.nodes[self.currentActionIndex].isHidden = false
            self.nodes[self.currentActionIndex].runAction(self.animation)
            self.updateStepText()
        } else {
            self.currentStep.text = "Construction done!"
            //self.shapeNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)))
        }
    }
    
    func prevAction(_ node: SCNNode) {
        node.removeAllActions()
        node.opacity = 1
        node.isHidden = true
        self.currentActionIndex -= 1
        self.nodes[self.currentActionIndex].opacity = 1
        self.nodes[self.currentActionIndex].isHidden = false
        self.nodes[self.currentActionIndex].runAction(self.animation)
        self.updateStepText()
    }
    
    func tryNextAction() {
        if (self.currentActionIndex < self.nodes.count) {
            self.nextAction(nodes[self.currentActionIndex])
            print(self.currentActionIndex)
        } else {
            print("No more steps!")
        }
    }
    
    func tryPrevAction() {
        if (self.currentActionIndex == self.nodes.count && self.nodes.count > 0) {
            //print("Assembly finished!")
            self.prevAction(nodes[self.currentActionIndex-1])
            print(self.currentActionIndex)
        } else if (self.currentActionIndex > 0) {
            self.prevAction(nodes[self.currentActionIndex])
            print(self.currentActionIndex)
        } else {
            print("No previous steps!")
        }
    }
    
    @objc func oneTapGestureFired(_ gesture: UITapGestureRecognizer) {self.tryNextAction()}
    
    @objc func twoTapGestureFired(_ gesture: UITapGestureRecognizer) {self.tryPrevAction()}
    
    @objc func longPressGestureFired(_ gesture: UILongPressGestureRecognizer) {
        guard let view = gesture.view else {return}
        let screenWidth = UIScreen.main.bounds.width
        let distancePerActionJump = Int(screenWidth) / (self.nodes.count + 1)
        
        if (gesture.state == .began) {
            self.initialPoint = gesture.location(in: view.superview)
            print("Action jump enabled!")
            self.currentStep.text = "Drag left / right to change steps"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {self.updateStepText()}
        } else if (gesture.state == .changed) {
            let currentPoint = gesture.location(in: view.superview)
            let dragDistanceX = currentPoint.x - initialPoint.x
            let currentActionShift = Int(dragDistanceX) / distancePerActionJump
            var relativeActionShift = 0
            if (self.lastActionShift != currentActionShift) {
                relativeActionShift = currentActionShift - self.lastActionShift
                self.lastActionShift = currentActionShift
                //print(relativeActionShift)
                for _ in 1...abs(relativeActionShift) {
                    if (relativeActionShift > 0) {
                        self.tryNextAction()
                    } else {
                        self.tryPrevAction()
                    }
                }
            }
        } else if (gesture.state == .ended) {
            self.lastActionShift = 0
            print("Action jump disabled!")
        }
    }
    
}
