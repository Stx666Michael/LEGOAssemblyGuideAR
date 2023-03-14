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

final class ARInstructionTests: XCTestCase {

    var sut: ViewController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStepChange() throws {
        sut.nc.initializeNodes()
        XCTAssertTrue(sut.nc.currentActionIndex == 0)
        sut.oneTapGestureFired()
        XCTAssertTrue(sut.nc.currentActionIndex == 1)
        XCTAssertTrue(sut.currentStep.text == "Step: 2 / 467")
        sut.twoTapGestureFired()
        XCTAssertTrue(sut.nc.currentActionIndex == 0)
        XCTAssertTrue(sut.currentStep.text == "Step: 1 / 467")
        
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
