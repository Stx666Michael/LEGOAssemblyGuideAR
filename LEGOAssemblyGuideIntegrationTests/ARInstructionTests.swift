//
//  ARInstructionTests.swift
//  LEGOAssemblyGuideIntegrationTests
//
//  Created by Tianxiang Song on 14/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import XCTest
import ARKit
@testable import LEGOAssemblyGuide

/// Integration tests for AR instruction flow
final class ARInstructionTests: XCTestCase {
    
    /// The system under test
    var sut: ViewController!
    
    /// The maximum number of assembly steps
    let maxStep = 467
    
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
    
    /// Tests to ensure that proper instruction could be presented under certain user action, including single finger tap, two fingers tap and press & drag.
    func testStepChange() throws {
        sut.nc.initializeNodes()
        XCTAssertTrue(sut.nc.currentActionIndex == 0)
        for i in 1...maxStep-1 {
            sut.oneTapGestureFired()
            XCTAssertTrue(sut.nc.currentActionIndex == i)
            XCTAssertTrue(sut.currentStep.text == "Step: " + String(i+1) + " / 467")
        }
        for i in 1...maxStep-1 {
            sut.twoTapGestureFired()
            XCTAssertTrue(sut.nc.currentActionIndex == maxStep-i-1)
            XCTAssertTrue(sut.currentStep.text == "Step: " + String(maxStep-i) + " / 467")
        }
        sut.initialPoint = CGPoint(x: 100, y: 100)
        sut.calculateStepChange(currentPoint: CGPoint(x: 200, y: 100))
        let stepIndex = sut.nc.currentActionIndex
        XCTAssertTrue(stepIndex > 0)
        sut.calculateStepChange(currentPoint: CGPoint(x: 150, y: 100))
        XCTAssertTrue(sut.nc.currentActionIndex < stepIndex)
        sut.calculateStepChange(currentPoint: CGPoint(x: 100, y: 100))
        XCTAssertTrue(sut.nc.currentActionIndex == 0)
    }

}
