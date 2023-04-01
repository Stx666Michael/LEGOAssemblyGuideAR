//
//  ViewControllerTests.swift
//  LEGOAssemblyGuideUnitTests
//
//  Created by Tianxiang Song on 12/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import XCTest
import ARKit
@testable import LEGOAssemblyGuide

/// Unit tests for class `ViewController`
final class ViewControllerTests: XCTestCase {
    
    /// The system under test
    var sut: ViewController!
    
    /// This method is called before the invocation of each test method in the class.
    override func setUpWithError() throws {
        // Put setup code here.
        sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        sut.loadViewIfNeeded()
    }
    
    /// This method is called after the invocation of each test method in the class.
    override func tearDownWithError() throws {
        // Put teardown code here.
    }
    
    /// Ensure screen elements could be initialized properly
    func testViewDidLoad() throws {
        XCTAssertNotNil(sut.sceneView, "ARSCNView should not be nil")
        XCTAssertNotEqual(sut.sceneView.debugOptions, ARSCNDebugOptions.showWireframe, "AR scene view debug options should not set to show wireframe")
        XCTAssertTrue(sut.sceneView.delegate === sut, "Scene View delegate must be set to the view controller instance")
        XCTAssertTrue(sut.currentStep.text == "Please scan marker to start")
        XCTAssertTrue(sut.functionalView.isHidden == true)
    }
    
    /// Ensure progress text showing correct content
    func testUpdateStepTest() throws {
        sut.nc.initializeNodes()
        sut.updateStepText()
        XCTAssertTrue(sut.currentStep.text == "Step: 1 / 467")
        
        sut.nc.currentActionIndex = 467
        sut.updateStepText()
        XCTAssertTrue(sut.currentStep.text == "Construction done!")
    }
    
    /// Ensure functional switches have correct initial states
    func testSetupSwitches() throws {
        sut.setupSwitches()
        XCTAssertTrue(sut.surface.isOn)
        XCTAssertTrue(sut.previous.isOn)
        XCTAssertTrue(sut.preview.isOn)
        XCTAssertFalse(sut.wireframe.isOn)
        XCTAssertFalse(sut.hand.isOn)
        XCTAssertFalse(sut.autostep.isOn)
        XCTAssertTrue(sut.prediction.isHidden)
    }

}
