//
//  ViewController.swift
//  LEGOAssemblyGuide
//
//  Created by Tianxiang Song on 05/10/22.
//  Copyright © 2022 Tianxiang Song. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

@available(iOS 13.0.0, *)
class ViewController: UIViewController, ARSCNViewDelegate {

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
    
    var nc = NodeController()
    var initialPoint = CGPoint()
    var configuration = ARImageTrackingConfiguration()
    var autoStepTimer = Timer()
    var model = try? LEGOStepClassifier(configuration: MLModelConfiguration())
    var tempView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate and show statistics
        sceneView.delegate = self
        //sceneView.showsStatistics = true
        
        // Create a new scene and set the scene to view
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
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
        self.prediction.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
                self.nc = NodeController()
                self.nc.initializeNodes()
                
                // Attach subscene to subsceneview
                self.subSceneView.scene = self.nc.subScene
                self.subSceneView.debugOptions.insert(SCNDebugOptions.showWireframe)
                
                self.nc.subScene.rootNode.addChildNode(self.nc.nodesInSubview.first!)
                self.updateStepText()
                node.addChildNode(self.nc.rootNode)
            }
        }
        return node
    }
    
    func updateStepText() {
        if (self.nc.currentActionIndex == self.nc.nodes.count) {
            self.currentStep.text = "Construction done!"
        } else {
            self.currentStep.text = "Step: " + String(self.nc.currentActionIndex+1) + " / " + String(self.nc.nodes.count)
        }
    }
    
    func modelPrediction(image: CGImage) -> [String: Double] {
        let resizedImage = UIImage(cgImage: image).resizeImageTo(size: CGSize(width: 299, height: 299))
        guard let imageBuffer = resizedImage?.convertToBuffer() else { return ["Unknown": 0]}
        let stepPrediction = try? self.model?.prediction(image: imageBuffer)
        let label = stepPrediction?.classLabel
        let probability = stepPrediction?.classLabelProbs
        self.prediction.text = label! + ": " + String(format: "%.2f", probability![label!]!)
        //print(label ?? "Unknown")
        //print(probability ?? 0)
        return probability ?? ["Unknown": 0]
    }
    
    func calculateStepScore(probability: [String: Double]) {
        self.nc.stepScore += probability["Finished"]! / 5
        self.nc.stepScore -= probability["Unfinished"]! / 5
        if (self.nc.stepScore < 0) {
            self.nc.stepScore = 0
        } else if (self.nc.stepScore > 1) {
            self.nc.stepScore = 1
        }
        //print("Step progress: " + String(format: "%.2f", self.stepScore*100) + "%")
        self.currentStep.text = "Step: " + String(self.nc.currentActionIndex+1) + " / " + String(self.nc.nodes.count) +
        " - Progress: " + String(format: "%.2f", self.nc.stepScore*100) + "%"
    }
    
    func stepDetection() {
        let crop = self.cropCurrentStep()
        let cropRect = crop.0
        
        if #available(iOS 16.0, *) {
            let image = CIContext().createCGImage(CIImage(image: self.sceneView.snapshot())!, from: cropRect)
            if (image != nil) {
                let probability = self.modelPrediction(image: image!)
                self.calculateStepScore(probability: probability)
                if (self.nc.stepScore == 1) {
                    self.nc.tryNextAction(isSurfaceOn: self.surface.isOn, isPreviousOn: self.previous.isOn)
                    self.updateStepText()
                }
                //UIImageWriteToSavedPhotosAlbum(UIImage(cgImage: image!), nil, nil, nil)
                //self.displayCurrentStepInSubview(image: image!, width: crop.1, height: crop.2)
            }
        }
    }
    
    func displayCurrentStepInSubview(image: CGImage, width: Float, height: Float) {
        self.tempView.removeFromSuperview()
        self.tempView = UIImageView(image: UIImage(cgImage: image))
        self.tempView.frame = CGRect(x: 50, y: 50, width: CGFloat(width*2), height: CGFloat(height*2))
        self.sceneView.addSubview(self.tempView)
    }
    
    func cropCurrentStep() -> (CGRect, Float, Float) {
        let node = self.nc.nodes[self.nc.currentActionIndex]
        let boundingBoxMin = node.convertPosition(node.boundingBox.min, to: nil)
        let boundingBoxMax = node.convertPosition(node.boundingBox.max, to: nil)
        let bbMinOnScreen = self.sceneView.projectPoint(boundingBoxMin)
        let bbMaxOnScreen = self.sceneView.projectPoint(boundingBoxMax)
        let windowSize = self.sceneView.frame
        let bbWidth = max(abs(bbMinOnScreen.x - bbMaxOnScreen.x), 20)
        let bbHeight = max(abs(bbMinOnScreen.y - bbMaxOnScreen.y), 20)
        //print(bbMinOnScreen.x, bbMinOnScreen.y)
        //print(bbMaxOnScreen.x, bbMaxOnScreen.y)
        let cropRect = CGRectMake(CGFloat(min(bbMinOnScreen.x, bbMaxOnScreen.x)*2),
                                  (windowSize.height - CGFloat(max(bbMinOnScreen.y, bbMaxOnScreen.y)))*2,
                                  CGFloat(bbWidth*2),
                                  CGFloat(bbHeight*2))
        return (cropRect, bbWidth, bbHeight)
    }
    
    @objc func oneTapGestureFired(_ gesture: UITapGestureRecognizer) {
        self.nc.tryNextAction(isSurfaceOn: self.surface.isOn, isPreviousOn: self.previous.isOn)
        self.updateStepText()
    }
    
    @objc func twoTapGestureFired(_ gesture: UITapGestureRecognizer) {
        self.nc.tryPrevAction()
        self.updateStepText()
    }
    
    @objc func longPressGestureFired(_ gesture: UILongPressGestureRecognizer) {
        guard let view = gesture.view else {return}
        let screenWidth = UIScreen.main.bounds.width
        let distancePerActionJump = Int(screenWidth) / (self.nc.nodes.count + 1)
        
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
    
    @objc func previewStateDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true) {
            self.subSceneView.isHidden = false
            print("Preview is now ON")
        } else {
            self.subSceneView.isHidden = true
            print("Preview is now Off")
        }
    }
    
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
                let opacity = self.nc.nodes[self.nc.currentActionIndex].opacity
                if (opacity < 0.25 && opacity > 0.05) {
                    self.stepDetection()
                }
            })
            print("Auto step is now ON")
        } else {
            self.prediction.isHidden = true
            self.updateStepText()
            self.tempView.removeFromSuperview()
            self.autoStepTimer.invalidate()
            print("Auto step is now Off")
        }
    }
    
}
