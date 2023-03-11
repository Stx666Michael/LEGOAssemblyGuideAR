//
//  ViewController.swift
//  LEGOAssemblyGuide
//
//  Created by Tianxiang Song on 05/10/22.
//  Copyright © 2022 Tianxiang Song. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

/// The class for user interaction with the application interface, and controller of the AR view
@available(iOS 13.0.0, *)
class ViewController: UIViewController, ARSCNViewDelegate {

    // Elements in the application interface
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var subSceneView: SCNView!
    @IBOutlet var currentStep: UILabel!
    @IBOutlet var surface: UISwitch!
    @IBOutlet var wireframe: UISwitch!
    @IBOutlet var hand: UISwitch!
    @IBOutlet var previous: UISwitch!
    @IBOutlet var preview: UISwitch!
    @IBOutlet var autostep: UISwitch!
    @IBOutlet var prediction: UILabel!
    
    /// The class storing digital models, and functions to display each model independently
    var nc = NodeController()
    
    /// The class storing CNN models, and functions to detect whether a construction step is finished
    var sc = StepController()
    
    /// Timer for automatic step detection
    var autoStepTimer = Timer()
    
    /// Initial point for press and drag action
    var initialPoint = CGPoint()
    
    /// A configuration that tracks known images using the rear-facing camera.
    var configuration = ARImageTrackingConfiguration()
    
    /// Called after the controller's view is loaded into memory, initialize screen elements and action recognizers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate and show statistics
        sceneView.delegate = self
        //sceneView.showsStatistics = true
        
        // Create a new scene and set the scene to view
        sceneView.scene = SCNScene(named: "art.scnassets/GameScene.scn")!
        
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
        
        // Add gesture recognizer
        sceneView.addGestureRecognizer(oneTapRecognizer)
        sceneView.addGestureRecognizer(twoTapRecognizer)
        sceneView.addGestureRecognizer(longPressRecognizer)
        sceneView.isUserInteractionEnabled = true
        
        // Add switch function
        surface.addTarget(self, action: #selector(self.surfaceStateDidChange(_:)), for: .valueChanged)
        wireframe.addTarget(self, action: #selector(self.wireframeStateDidChange(_:)), for: .valueChanged)
        hand.addTarget(self, action: #selector(self.handStateDidChange(_:)), for: .valueChanged)
        previous.addTarget(self, action: #selector(self.previousStateDidChange(_:)), for: .valueChanged)
        preview.addTarget(self, action: #selector(self.previewStateDidChange(_:)), for: .valueChanged)
        autostep.addTarget(self, action: #selector(self.autostepStateDidChange(_:)), for: .valueChanged)
        
        // Setup switch state
        wireframe.setOn(false, animated: true)
        hand.setOn(false, animated: true)
        autostep.setOn(false, animated: true)
        prediction.isHidden = true
        
        // Setup for UI testing
        self.sceneView.accessibilityIdentifier = "AR Scene View"
        self.subSceneView.accessibilityIdentifier = "Sub Scene View"
        self.surface.accessibilityIdentifier = "Surface"
        self.wireframe.accessibilityIdentifier = "Wireframe"
        self.hand.accessibilityIdentifier = "Hand"
        self.previous.accessibilityIdentifier = "Previous"
        self.preview.accessibilityIdentifier = "Preview"
        self.autostep.accessibilityIdentifier = "Autostep"
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameter animated: If true, the view is being added to the window using an animation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure AR image marker for model alignment
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: Bundle.main) else {
            print("No images available")
            return
        }
        configuration.trackingImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 1
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    /// Notifies the view controller that its view is about to be removed from a view hierarchy.
    /// - Parameter animated: If true, the disappearance of the view is being animated.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    /// Inherited from ARSCNViewDelegate.renderer(_:nodeFor:).
    /// - Parameters:
    ///   - renderer: The SCN scene renderer, display a scene and manage SceneKit's rendering and animation of the scene's contents.
    ///   - anchor: An object that specifies the position and orientation of an item in the physical environment.
    /// - Returns: The SCN node to be rendered
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        DispatchQueue.main.async {
            if anchor is ARImageAnchor {
                // Initialize instances of NodeController and StepController
                self.nc.initializeNodes()
                self.sc = StepController(nc: self.nc)
                
                // Attach subscene to subsceneview
                self.subSceneView.scene = self.nc.subScene
                self.subSceneView.debugOptions.insert(SCNDebugOptions.showWireframe)
                
                self.updateStepText()
                node.addChildNode(self.nc.rootNode)
            }
        }
        return node
    }
    
    /// Update text in the top of screen showing construction progress
    func updateStepText() {
        if (self.nc.currentActionIndex == self.nc.nodes.count) {
            self.currentStep.text = "Construction done!"
        } else {
            self.currentStep.text = "Step: " + String(self.nc.currentActionIndex+1) + " / " + String(self.nc.nodes.count)
        }
    }
    
    /// Response to one finger tap on screen (proceed to the next instruction step)
    /// - Parameter gesture: Finger tap gesture recognizer
    @objc func oneTapGestureFired(_ gesture: UITapGestureRecognizer) {
        self.nc.tryNextAction(isSurfaceOn: self.surface.isOn, isPreviousOn: self.previous.isOn)
        self.updateStepText()
    }
    
    /// Response to two finger tap on screen (back to the previous instruction step)
    /// - Parameter gesture: Finger tap gesture recognizer
    @objc func twoTapGestureFired(_ gesture: UITapGestureRecognizer) {
        self.nc.tryPrevAction()
        self.updateStepText()
    }
    
    /// Response to one finger long press and drag on screen (drag left - fast go to previous steps, drag right - the reverse)
    /// - Parameter gesture: Finger long press gesture recognizer
    @objc func longPressGestureFired(_ gesture: UILongPressGestureRecognizer) {
        guard let view = gesture.view else {return}
        let screenWidth = UIScreen.main.bounds.width
        let distancePerActionJump = max(Int(screenWidth)/(self.nc.nodes.count+1), 1)
        
        if (gesture.state == .began) {
            self.initialPoint = gesture.location(in: view.superview)
            print("Action jump enabled!")
            self.currentStep.text = "Drag left / right to change steps"
        } else if (gesture.state == .changed) {
            let currentPoint = gesture.location(in: view.superview)
            let dragDistanceX = currentPoint.x - initialPoint.x
            let currentActionShift = Int(dragDistanceX) / distancePerActionJump
            var relativeActionShift = 0
            if (self.nc.lastActionShift != currentActionShift) {
                relativeActionShift = currentActionShift - self.nc.lastActionShift
                self.nc.lastActionShift = currentActionShift
                //print(relativeActionShift)
                for _ in 1...abs(relativeActionShift) {
                    if (relativeActionShift > 0) {
                        self.nc.tryNextAction(isSurfaceOn: self.surface.isOn, isPreviousOn: self.previous.isOn)
                    } else {
                        self.nc.tryPrevAction()
                    }
                    self.updateStepText()
                }
            }
        } else if (gesture.state == .ended) {
            self.updateStepText()
            self.nc.lastActionShift = 0
            print("Action jump disabled!")
        }
    }
    
    /// Response to changes in switch "surface" - render models with colored, physical-based materials
    /// - Parameter sender: Switch "surface"
    @objc func surfaceStateDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true) {
            for node in self.nc.nodes[...(self.nc.currentActionIndex-1)] {
                node.opacity = 1
            }
            print("Surface rendering is now ON")
        } else {
            for node in self.nc.nodes[...(self.nc.currentActionIndex-1)] {
                node.opacity = 0.01
            }
            print("Surface rendering is now Off")
        }
    }
    
    /// Response to changes in switch "wireframe" - display the wireframe of each virtual block
    /// - Parameter sender: Switch "wireframe"
    @objc func wireframeStateDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true) {
            if (self.hand.isOn) {
                let alert = UIAlertController(title: "Warning", message: "Wireframe rendering does not work while hand occlusion is ON", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    sender.setOn(false, animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.sceneView.debugOptions.insert(SCNDebugOptions.showWireframe)
                print("Wireframe rendering is now ON")
            }
        } else {
            self.sceneView.debugOptions.remove(SCNDebugOptions.showWireframe)
            print("Wireframe rendering is now Off")
        }
    }
    
    /// Response to changes in switch "hand" - open realtime hand occlusion
    /// - Parameter sender: Switch "hand"
    @objc func handStateDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
            if (self.wireframe.isOn) {
                self.wireframe.setOn(false, animated: true)
                self.sceneView.debugOptions.remove(SCNDebugOptions.showWireframe)
            }
            print("Hand occlusion is now ON")
        } else {
            configuration.frameSemantics.remove(.personSegmentationWithDepth)
            print("Hand occlusion is now Off")
        }
        sceneView.session.run(configuration)
    }
    
    /// Response to changes in switch "previous" - display all virtual bricks in previous construction
    /// - Parameter sender: Switch "previous"
    @objc func previousStateDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true) {
            for node in self.nc.nodes[...(self.nc.currentActionIndex-1)] {
                node.isHidden = false
            }
            print("Previous steps is now ON")
        } else {
            for node in self.nc.nodes[...(self.nc.currentActionIndex-1)] {
                node.isHidden = true
            }
            print("Previous steps is now Off")
        }
    }
    
    /// Response to changes in switch "preview" - display the virtual model of current construction block with rotating animation separately in preview window below the progress bar
    /// - Parameter sender: Switch "preview"
    @objc func previewStateDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true) {
            self.subSceneView.isHidden = false
            print("Preview is now ON")
        } else {
            self.subSceneView.isHidden = true
            print("Preview is now Off")
        }
    }
    
    /// Response to changes in switch "autostep" - detect whether the current step is finished of not, and proceed to next step automatically
    /// - Parameter sender: Switch "autostep"
    @objc func autostepStateDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true) {
            self.prediction.isHidden = false
            if (!self.wireframe.isOn) {
                self.wireframe.setOn(true, animated: true)
                self.sceneView.debugOptions.insert(SCNDebugOptions.showWireframe)
            }
            if (self.previous.isOn) {
                self.previous.setOn(false, animated: true)
                for node in self.nc.nodes[...(self.nc.currentActionIndex-1)] {node.isHidden = true}
            }
            if (self.preview.isOn) {
                self.preview.setOn(false, animated: true)
                self.subSceneView.isHidden = true
            }
            let timeInterval = 0.1
            self.autoStepTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { _ in
                if (self.nc.currentActionIndex < self.nc.nodes.count) {
                    let opacity = self.nc.nodes[self.nc.currentActionIndex].opacity
                    if (opacity < 0.25 && opacity > 0.05) {
                        if (self.sc.stepDetection(sceneView: self.sceneView, prediction: self.prediction, currentStep: self.currentStep)) {
                            self.nc.tryNextAction(isSurfaceOn: self.surface.isOn, isPreviousOn: self.previous.isOn)
                            self.updateStepText()
                        }
                    }
                }
            })
            print("Auto step is now ON")
        } else {
            self.prediction.isHidden = true
            self.updateStepText()
            self.sc.tempView.removeFromSuperview()
            self.autoStepTimer.invalidate()
            print("Auto step is now Off")
        }
    }
    
}
