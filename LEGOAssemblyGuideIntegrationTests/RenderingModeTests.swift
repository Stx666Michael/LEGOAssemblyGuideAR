//
//  RenderingModeTests.swift
//  LEGOAssemblyGuideIntegrationTests
//
//  Created by Tianxiang Song on 01/04/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import XCTest
import ARKit
@testable import LEGOAssemblyGuide

final class RenderingModeTests: XCTestCase {
    
    var sut: ViewController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        sut.loadViewIfNeeded()
        sut.nc.initializeNodes()
        sut.setupSwitches()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSurfaceMode() throws {
        for _ in 1...100 {sut.oneTapGestureFired()}
        for node in sut.nc.nodes[...(sut.nc.currentActionIndex-1)] {
            XCTAssertTrue(node.opacity == 1)
        }
        sut.surface.isOn = false
        sut.surfaceStateDidChange(sender: sut.surface)
        for _ in 1...100 {sut.oneTapGestureFired()}
        for node in sut.nc.nodes[...(sut.nc.currentActionIndex-1)] {
            XCTAssertFalse(node.opacity == 1)
        }
        sut.surface.isOn = true
        sut.surfaceStateDidChange(sender: sut.surface)
        for _ in 1...100 {sut.oneTapGestureFired()}
        for node in sut.nc.nodes[...(sut.nc.currentActionIndex-1)] {
            XCTAssertTrue(node.opacity == 1)
        }
    }
    
    func testWireframeMode() throws {
        XCTAssertFalse(sut.sceneView.debugOptions.contains(SCNDebugOptions.showWireframe))
        sut.wireframe.isOn = true
        sut.wireframeStateDidChange(sender: sut.wireframe)
        XCTAssertTrue(sut.sceneView.debugOptions.contains(SCNDebugOptions.showWireframe))
        sut.wireframe.isOn = false
        sut.wireframeStateDidChange(sender: sut.wireframe)
        XCTAssertFalse(sut.sceneView.debugOptions.contains(SCNDebugOptions.showWireframe))
    }
    
    func testPreviousMode() throws {
        for _ in 1...100 {sut.oneTapGestureFired()}
        for node in sut.nc.nodes[...(sut.nc.currentActionIndex-1)] {
            XCTAssertTrue(node.isHidden == false)
        }
        sut.previous.isOn = false
        sut.previousStateDidChange(sender: sut.previous)
        for _ in 1...100 {sut.oneTapGestureFired()}
        for node in sut.nc.nodes[...(sut.nc.currentActionIndex-1)] {
            XCTAssertTrue(node.isHidden == true)
        }
        sut.previous.isOn = true
        sut.previousStateDidChange(sender: sut.previous)
        for _ in 1...100 {sut.oneTapGestureFired()}
        for node in sut.nc.nodes[...(sut.nc.currentActionIndex-1)] {
            XCTAssertTrue(node.isHidden == false)
        }
    }
    
    func testPreviewMode() throws {
        sut.subSceneView.scene = sut.nc.subScene
        XCTAssertFalse(sut.subSceneView.isHidden)
        sut.preview.isOn = false
        sut.previewStateDidChange(sender: sut.preview)
        XCTAssertTrue(sut.subSceneView.isHidden)
        sut.preview.isOn = true
        sut.previewStateDidChange(sender: sut.preview)
        XCTAssertFalse(sut.subSceneView.isHidden)
    }

}
