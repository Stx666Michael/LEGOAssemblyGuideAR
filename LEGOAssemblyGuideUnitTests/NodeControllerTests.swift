//
//  NodeControllerTests.swift
//  LEGOAssemblyGuideUnitTests
//
//  Created by Tianxiang Song on 05/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import XCTest
@testable import LEGOAssemblyGuide

/// Unit tests for class `NodeController`
final class NodeControllerTests: XCTestCase {
    
    /// The system under test
    let sut = NodeController()
    
    /// The maximum number of assembly steps
    let maxStep = 467
    
    /// This method is called before the invocation of each test method in the class.
    override func setUpWithError() throws {
        // Put setup code here.
        sut.initializeNodes()
    }
    
    /// This method is called after the invocation of each test method in the class.
    override func tearDownWithError() throws {
        // Put teardown code here.
    }
    
    /// Ensure the number of nodes (AR models) stored in the list is correct
    func testInitializeNodes() throws {
        XCTAssertTrue(sut.nodes.count == maxStep)
        XCTAssertTrue(sut.nodesInSubview.count == maxStep)
    }
    
    /// Ensure the next AR instruction could be presented correctly
    func testNextAction() throws {
        sut.nextAction(isSurfaceOn: true, isPreviousOn: true)
        XCTAssertTrue(sut.currentActionIndex == 1)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex].isHidden == false)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex-1].isHidden == false)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex-1].opacity == 1)
        
        sut.nextAction(isSurfaceOn: false, isPreviousOn: true)
        XCTAssertTrue(sut.currentActionIndex == 2)
        XCTAssertFalse(sut.nodes[sut.currentActionIndex-1].opacity == 1)
        
        sut.nextAction(isSurfaceOn: false, isPreviousOn: false)
        XCTAssertTrue(sut.currentActionIndex == 3)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex-1].isHidden == true)
    }
    
    /// Ensure the previous AR instruction could be presented correctly
    func testPrevAction() throws {
        sut.nextAction(isSurfaceOn: false, isPreviousOn: false)
        sut.nextAction(isSurfaceOn: false, isPreviousOn: false)
        
        sut.prevAction(isLastAction: false)
        XCTAssertTrue(sut.currentActionIndex == 1)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex+1].isHidden == true)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex].isHidden == false)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex].opacity == 1)
        
        sut.tryPrevAction()
        XCTAssertTrue(sut.currentActionIndex == 0)
    }
    
    /// Ensure boundary cases are handled (no next instruction)
    func testTryNextAction() throws {
        sut.tryNextAction(isSurfaceOn: true, isPreviousOn: true)
        XCTAssertTrue(sut.currentActionIndex == 1)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex].isHidden == false)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex-1].isHidden == false)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex-1].opacity == 1)
        
        sut.tryNextAction(isSurfaceOn: false, isPreviousOn: true)
        XCTAssertTrue(sut.currentActionIndex == 2)
        XCTAssertFalse(sut.nodes[sut.currentActionIndex-1].opacity == 1)
        
        sut.tryNextAction(isSurfaceOn: false, isPreviousOn: false)
        XCTAssertTrue(sut.currentActionIndex == 3)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex-1].isHidden == true)
        
        for _ in 1...500 {
            sut.tryNextAction(isSurfaceOn: true, isPreviousOn: true)
        }
        XCTAssertTrue(sut.currentActionIndex == maxStep)
    }
    
    /// Ensure boundary cases are handled (no previous instruction)
    func testTryPrevAction() throws {
        sut.tryNextAction(isSurfaceOn: false, isPreviousOn: false)
        sut.tryPrevAction()
        XCTAssertTrue(sut.currentActionIndex == 0)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex+1].isHidden == true)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex].isHidden == false)
        XCTAssertTrue(sut.nodes[sut.currentActionIndex].opacity == 1)
        
        sut.tryPrevAction()
        XCTAssertTrue(sut.currentActionIndex == 0)
        
        for _ in 1...500 {
            sut.tryNextAction(isSurfaceOn: true, isPreviousOn: true)
        }
        sut.tryPrevAction()
        XCTAssertTrue(sut.currentActionIndex == maxStep-1)
    }

}
