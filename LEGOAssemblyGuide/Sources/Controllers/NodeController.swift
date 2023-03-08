//
//  NodeController.swift
//  LEGOAssemblyGuide
//
//  Created by Tianxiang Song on 04/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import SceneKit

@available(iOS 13.0.0, *)
/// The class storing digital models, and functions to display each model independently
class NodeController {
    
    /// Root node of all digital models
    var rootNode = SCNScene(named: "art.scnassets/LEGO.scn")!.rootNode
    
    /// The scene for individual model preview
    var subScene = SCNScene(named: "art.scnassets/LEGO.scn")!
    
    /// The lists storing digital models sequentially to be displayed as in-situ instruction
    var nodes = [SCNNode]()
    
    /// The lists storing digital models sequentially to be displayed in preview window
    var nodesInSubview = [SCNNode]()
    
    /// The animation of each digital model
    var animation = SCNAction()
    
    /// The index of current instruction step
    var currentActionIndex = 0
    
    /// Drag distance to calculate number of action shift
    var lastActionShift = 0
    
    /// Confidence score of one step between 0 and 1
    var stepScore = Double(0)
    
    /// Take nodes from the SCN graph sequentially into the list, and setup their animations
    func initializeNodes() {
        self.subScene.rootNode.childNode(withName: "Lego_21034_1_London", recursively: true)?.removeFromParentNode()
        self.rootNode.position = SCNVector3(x: -10, y: 0, z: 0)
        //self.rootNode.eulerAngles.y = -.pi / 2
        let subviewAction = SCNAction.repeatForever(SCNAction.rotateBy(x: .pi, y: 0, z: .pi, duration: 5))
        
        for firstIndex in "abcdefghijklmnopqr" {
            for secondIndex in "abcdefghijklmnopqrstuvwxyz" {
                let index = String(firstIndex) + String(secondIndex)
                let nodeToAdd = self.rootNode.childNode(withName: index, recursively: true)
                if nodeToAdd != nil {
                    let nodeClone = nodeToAdd!.clone()
                    nodeClone.position = SCNVector3Zero
                    nodeClone.runAction(subviewAction)
                    self.nodesInSubview.append(nodeClone)
                    nodeToAdd!.isHidden = true
                    self.nodes.append(nodeToAdd!)
                }
            }
        }
        
        let duration = 0.5
        let fadeOut = SCNAction.fadeOpacity(by: -1, duration: duration)
        let fadeIn = SCNAction.fadeOpacity(by: 1, duration: duration)
        self.animation = SCNAction.repeatForever(SCNAction.sequence([fadeOut, fadeIn]))
        
        self.nodes.first?.isHidden = false
        self.nodes.first?.runAction(self.animation)
        self.subScene.rootNode.addChildNode(self.nodesInSubview.first!)
    }
    
    /// Present the next model-based instruction
    /// - Parameters:
    ///   - node: The current digital model for in-situ instruction
    ///   - previewNode: The current digital model for preview
    ///   - isSurfaceOn: True if the "surface" switch is turned on
    ///   - isPreviousOn: True if the "previous" switch is turned on
    func nextAction(node: SCNNode, previewNode: SCNNode, isSurfaceOn: Bool, isPreviousOn: Bool) {
        node.removeAllActions()
        previewNode.removeFromParentNode()
        self.currentActionIndex += 1
        self.stepScore = 0
        
        if (isSurfaceOn) {
            node.opacity = 1
        } else {
            node.opacity = 0.01
        }
        if (!isPreviousOn) {
            node.isHidden = true
        }
        if (self.currentActionIndex < self.nodes.count) {
            self.nodes[self.currentActionIndex].isHidden = false
            self.nodes[self.currentActionIndex].runAction(self.animation)
            self.subScene.rootNode.addChildNode(self.nodesInSubview[self.currentActionIndex])
        }
    }
    
    /// Present the previous model-based instruction
    /// - Parameters:
    ///   - node: The current digital model for in-situ instruction
    ///   - previewNode: The current digital model for preview
    func prevAction(node: SCNNode, previewNode: SCNNode) {
        node.removeAllActions()
        node.opacity = 1
        node.isHidden = true
        previewNode.removeFromParentNode()
        self.currentActionIndex -= 1
        self.stepScore = 0
        self.nodes[self.currentActionIndex].opacity = 1
        self.nodes[self.currentActionIndex].isHidden = false
        self.nodes[self.currentActionIndex].runAction(self.animation)
        self.subScene.rootNode.addChildNode(self.nodesInSubview[self.currentActionIndex])
    }
    
    /// Try to present the next model-based instruction, if it is not at the last step
    /// - Parameters:
    ///   - isSurfaceOn: True if the "surface" switch is turned on
    ///   - isPreviousOn: True if the "previous" switch is turned on
    func tryNextAction(isSurfaceOn: Bool, isPreviousOn: Bool) {
        if (self.currentActionIndex < self.nodes.count) {
            self.nextAction(node: nodes[self.currentActionIndex], previewNode: nodesInSubview[self.currentActionIndex], isSurfaceOn: isSurfaceOn, isPreviousOn: isPreviousOn)
            print(self.currentActionIndex)
        } else {
            print("No more steps!")
        }
    }
    
    /// Try to present the previous model-based instruction, if it is not at the first step
    func tryPrevAction() {
        if (self.currentActionIndex == self.nodes.count && self.nodes.count > 0) {
            //print("Assembly finished!")
            self.prevAction(node: nodes[self.currentActionIndex-1], previewNode: nodesInSubview[self.currentActionIndex-1])
            print(self.currentActionIndex)
        } else if (self.currentActionIndex > 0) {
            self.prevAction(node: nodes[self.currentActionIndex], previewNode: nodesInSubview[self.currentActionIndex])
            print(self.currentActionIndex)
        } else {
            print("No previous steps!")
        }
    }
    
}
