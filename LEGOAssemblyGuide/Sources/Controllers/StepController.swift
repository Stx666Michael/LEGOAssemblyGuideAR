//
//  StepController.swift
//  LEGOAssemblyGuide
//
//  Created by Tianxiang Song on 04/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import UIKit
import ARKit

@available(iOS 13.0.0, *)
/// The class storing CNN models, and functions to detect whether a construction step is finished
class StepController {
    
    /// Set true to save image within bounding box of every step, to collet training data
    let saveImage = false
    
    /// The class storing digital models, and functions to display each model independently
    var nc = NodeController()
    
    /// The small window displaying content within bounding box of every step
    var tempView = UIImageView()
    
    /// Pre-trained MobileNetV2 model for step classification
    var model = try? LEGOStepClassifier(configuration: MLModelConfiguration())
    
    /// Initialize with a NodeController inside
    /// - Parameter nc: The class storing digital models, and functions to display each model independently
    init(nc: NodeController = NodeController()) {
        self.nc = nc
    }
    
    /// Get completeness score of current construction step, and decide whether the step is finished
    /// - Parameters:
    ///   - sceneView: The view that blends virtual 3D content from SceneKit into augmented reality experience
    ///   - prediction: The UI text showing the prediction result with probability
    ///   - currentStep: The UI text showing current step progress
    /// - Returns: `true` if the completeness score of current construction step is 1, `false` otherwise
    func stepDetection(sceneView: ARSCNView, prediction: UILabel, currentStep: UILabel) -> Bool {
        let crop = self.getBoundingBox(sceneView: sceneView)
        let cropRect = crop.0
        
        if #available(iOS 16.0, *) {
            let image = CIContext().createCGImage(CIImage(image: sceneView.snapshot())!, from: cropRect)
            if (image != nil) {
                let probability = self.modelPrediction(image: image!, prediction: prediction)
                self.calculateStepScore(probability: probability, currentStep: currentStep)
                if (self.nc.stepScore == 1) {return true}
                if (saveImage) {
                    UIImageWriteToSavedPhotosAlbum(UIImage(cgImage: image!), nil, nil, nil)
                    self.displayCurrentStepInSubview(sceneView: sceneView, image: image!, width: crop.1, height: crop.2)
                }
            }
        }
        return false
    }
    
    /// Get the bounding box of current instruction digital model
    /// - Parameter sceneView: The view that blends virtual 3D content from SceneKit into augmented reality experience
    /// - Returns: The bounding box, the width of tempView, the height of tempView (see its declaration at the beginning)
    func getBoundingBox(sceneView: ARSCNView) -> (CGRect, Float, Float) {
        let node = self.nc.nodes[self.nc.currentActionIndex]
        let boundingBoxMin = node.convertPosition(node.boundingBox.min, to: nil)
        let boundingBoxMax = node.convertPosition(node.boundingBox.max, to: nil)
        let bbMinOnScreen = sceneView.projectPoint(boundingBoxMin)
        let bbMaxOnScreen = sceneView.projectPoint(boundingBoxMax)
        let windowSize = sceneView.frame
        let bbWidth = max(abs(bbMinOnScreen.x - bbMaxOnScreen.x), 20)
        let bbHeight = max(abs(bbMinOnScreen.y - bbMaxOnScreen.y), 20)
        let cropRect = CGRectMake(CGFloat(min(bbMinOnScreen.x, bbMaxOnScreen.x)*2),
                                  (windowSize.height - CGFloat(max(bbMinOnScreen.y, bbMaxOnScreen.y)))*2,
                                  CGFloat(bbWidth*2),
                                  CGFloat(bbHeight*2))
        return (cropRect, bbWidth, bbHeight)
    }
    
    /// Get the probability of step classification result
    /// - Parameters:
    ///   - image: The image of current step to be classified
    ///   - prediction: The UI text showing the prediction result with probability
    /// - Returns: List with prediction labels and their probability
    func modelPrediction(image: CGImage, prediction: UILabel) -> [String: Double] {
        let resizedImage = UIImage(cgImage: image).resizeImageTo(size: CGSize(width: 299, height: 299))
        guard let imageBuffer = resizedImage?.convertToBuffer() else { return ["Unknown": 0]}
        let stepPrediction = try? self.model?.prediction(image: imageBuffer)
        let label = stepPrediction?.classLabel
        let probability = stepPrediction?.classLabelProbs
        prediction.text = label! + ": " + String(format: "%.2f", probability![label!]!)
        return probability ?? ["Unknown": 0]
    }
    
    /// Calculate completeness score of current step
    /// - Parameters:
    ///   - probability: List with prediction labels and their probability
    ///   - currentStep: The UI text showing current step progress
    func calculateStepScore(probability: [String: Double], currentStep: UILabel) {
        self.nc.stepScore += probability["Finished"]! / 5
        self.nc.stepScore -= probability["Unfinished"]! / 5
        if (self.nc.stepScore < 0) {
            self.nc.stepScore = 0
        } else if (self.nc.stepScore > 1) {
            self.nc.stepScore = 1
        }
        //print("Step progress: " + String(format: "%.2f", self.stepScore*100) + "%")
        currentStep.text = "Step: " + String(self.nc.currentActionIndex+1) + " / " + String(self.nc.nodes.count) +
        " - Progress: " + String(format: "%.2f", self.nc.stepScore*100) + "%"
    }
    
    /// Display content within bounding box of every step in a small window
    /// - Parameters:
    ///   - sceneView: The view that blends virtual 3D content from SceneKit into augmented reality experience
    ///   - image: The content within bounding box of every step
    ///   - width: The width of display window
    ///   - height: The height of display window
    func displayCurrentStepInSubview(sceneView: ARSCNView, image: CGImage, width: Float, height: Float) {
        self.tempView.removeFromSuperview()
        self.tempView = UIImageView(image: UIImage(cgImage: image))
        self.tempView.frame = CGRect(x: 50, y: 50, width: CGFloat(width*2), height: CGFloat(height*2))
        sceneView.addSubview(self.tempView)
    }
    
}
