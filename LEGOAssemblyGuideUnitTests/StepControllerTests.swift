//
//  StepControllerTests.swift
//  LEGOAssemblyGuideUnitTests
//
//  Created by Tianxiang Song on 11/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import XCTest
@testable import LEGOAssemblyGuide

/// Unit tests for class `StepController`
final class StepControllerTests: XCTestCase {
    
    /// Mocked class `NodeController` for unit testing
    let nc = NodeController()
    
    /// The system under test
    var sut: StepController!
    
    /// This method is called before the invocation of each test method in the class.
    override func setUpWithError() throws {
        // Put setup code here.
        sut = StepController(nc: self.nc)
    }
    
    /// This method is called after the invocation of each test method in the class.
    override func tearDownWithError() throws {
        // Put teardown code here.
    }
    
    /// Ensure step score is properly calculated given CNN predictions
    func testCalculateStepScore() throws {
        sut.calculateStepScore(probability: ["Finished": 0.1, "Unfinished": 0.9], currentStep: UILabel())
        XCTAssertTrue(nc.stepScore == 0)
        
        sut.calculateStepScore(probability: ["Finished": 0.6, "Unfinished": 0.4], currentStep: UILabel())
        XCTAssertTrue(nc.stepScore > 0.03 && nc.stepScore < 0.05)
        
        for _ in 1...5 {
            sut.calculateStepScore(probability: ["Finished": 1.0, "Unfinished": 0.0], currentStep: UILabel())
        }
        XCTAssertTrue(nc.stepScore == 1)
    }

}
