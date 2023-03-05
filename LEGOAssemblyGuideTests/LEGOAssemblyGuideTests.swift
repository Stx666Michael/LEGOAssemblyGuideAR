//
//  LEGOAssemblyGuideTests.swift
//  LEGOAssemblyGuideTests
//
//  Created by Tianxiang Song on 05/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import XCTest
import ARKit
@testable import LEGOAssemblyGuide

final class LEGOAssemblyGuideTests: XCTestCase {
    
    let nc = NodeController()
    
    override func setUpWithError() throws {
        nc.initializeNodes()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitializeNodes() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        XCTAssertTrue(nc.nodes.count == 467)
        XCTAssertTrue(nc.nodesInSubview.count == 467)
    }
    
    func testTryNextAction() throws {
        nc.tryNextAction(isSurfaceOn: true, isPreviousOn: true)
        XCTAssertTrue(nc.currentActionIndex == 1)
        XCTAssertTrue(nc.nodes[nc.currentActionIndex].isHidden == false)
        XCTAssertTrue(nc.nodes[nc.currentActionIndex-1].isHidden == false)
        XCTAssertTrue(nc.nodes[nc.currentActionIndex-1].opacity == 1)
        
        nc.tryNextAction(isSurfaceOn: false, isPreviousOn: true)
        XCTAssertTrue(nc.currentActionIndex == 2)
        XCTAssertFalse(nc.nodes[nc.currentActionIndex-1].opacity == 1)
        
        nc.tryNextAction(isSurfaceOn: false, isPreviousOn: false)
        XCTAssertTrue(nc.currentActionIndex == 3)
        XCTAssertTrue(nc.nodes[nc.currentActionIndex-1].isHidden == true)
        
        for _ in 1...500 {
            nc.tryNextAction(isSurfaceOn: true, isPreviousOn: true)
        }
        XCTAssertTrue(nc.currentActionIndex == 467)
    }
    
    func testTryPrevAction() throws {
        nc.tryNextAction(isSurfaceOn: false, isPreviousOn: false)
        nc.tryPrevAction()
        XCTAssertTrue(nc.currentActionIndex == 0)
        XCTAssertTrue(nc.nodes[nc.currentActionIndex+1].isHidden == true)
        XCTAssertTrue(nc.nodes[nc.currentActionIndex].isHidden == false)
        XCTAssertTrue(nc.nodes[nc.currentActionIndex].opacity == 1)
        
        nc.tryPrevAction()
        XCTAssertTrue(nc.currentActionIndex == 0)
    }
    
    func testCalculateStepScore() throws {
        let sc = StepController(nc: self.nc)
        sc.calculateStepScore(probability: ["Finished": 0.1, "Unfinished": 0.9], currentStep: UILabel())
        XCTAssertTrue(nc.stepScore == 0)
        
        sc.calculateStepScore(probability: ["Finished": 0.6, "Unfinished": 0.4], currentStep: UILabel())
        XCTAssertTrue(nc.stepScore > 0.03 && nc.stepScore < 0.05)
        
        for _ in 1...5 {
            sc.calculateStepScore(probability: ["Finished": 1.0, "Unfinished": 0.0], currentStep: UILabel())
        }
        XCTAssertTrue(nc.stepScore == 1)
    }

}
