//
//  StepController.swift
//  LEGOAssemblyGuide
//
//  Created by Tianxiang Song on 04/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import UIKit
import ARKit
import CoreML

@available(iOS 13.0.0, *)
class StepController {
        
    var nc = NodeController()
    var tempView = UIImageView()
    var model = try? LEGOStepClassifier(configuration: MLModelConfiguration())
    
    init(nc: NodeController = NodeController()) {
        self.nc = nc
    }
    
    func stepDetection(sceneView: ARSCNView, prediction: UILabel, currentStep: UILabel) -> Bool {
        let crop = self.cropCurrentStep(sceneView: sceneView)
        let cropRect = crop.0
        
        if #available(iOS 16.0, *) {
            let image = CIContext().createCGImage(CIImage(image: sceneView.snapshot())!, from: cropRect)
            if (image != nil) {
                let probability = self.modelPrediction(image: image!, prediction: prediction)
                self.calculateStepScore(probability: probability, currentStep: currentStep)
                if (self.nc.stepScore == 1) {
                    return true
                }
                //UIImageWriteToSavedPhotosAlbum(UIImage(cgImage: image!), nil, nil, nil)
                //self.displayCurrentStepInSubview(sceneView: sceneView, image: image!, width: crop.1, height: crop.2)
            }
        }
        return false
    }
    
    func cropCurrentStep(sceneView: ARSCNView) -> (CGRect, Float, Float) {
        let node = self.nc.nodes[self.nc.currentActionIndex]
        let boundingBoxMin = node.convertPosition(node.boundingBox.min, to: nil)
        let boundingBoxMax = node.convertPosition(node.boundingBox.max, to: nil)
        let bbMinOnScreen = sceneView.projectPoint(boundingBoxMin)
        let bbMaxOnScreen = sceneView.projectPoint(boundingBoxMax)
        let windowSize = sceneView.frame
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
    
    func modelPrediction(image: CGImage, prediction: UILabel) -> [String: Double] {
        let resizedImage = UIImage(cgImage: image).resizeImageTo(size: CGSize(width: 299, height: 299))
        guard let imageBuffer = resizedImage?.convertToBuffer() else { return ["Unknown": 0]}
        let stepPrediction = try? self.model?.prediction(image: imageBuffer)
        let label = stepPrediction?.classLabel
        let probability = stepPrediction?.classLabelProbs
        prediction.text = label! + ": " + String(format: "%.2f", probability![label!]!)
        //print(label ?? "Unknown")
        //print(probability ?? 0)
        return probability ?? ["Unknown": 0]
    }
    
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
    
    func displayCurrentStepInSubview(sceneView: ARSCNView, image: CGImage, width: Float, height: Float) {
        self.tempView.removeFromSuperview()
        self.tempView = UIImageView(image: UIImage(cgImage: image))
        self.tempView.frame = CGRect(x: 50, y: 50, width: CGFloat(width*2), height: CGFloat(height*2))
        sceneView.addSubview(self.tempView)
    }
    
}
