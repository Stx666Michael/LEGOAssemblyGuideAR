//
//  NodeControllerTests.swift
//  LEGOAssemblyGuideUnitTests
//
//  Created by Tianxiang Song on 05/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import XCTest
@testable import LEGOAssemblyGuide

final class NodeControllerTests: XCTestCase {
    
    let sut = NodeController()
    let maxStep = 467
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut.initializeNodes()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitializeNodes() throws {
        XCTAssertTrue(sut.nodes.count == maxStep)
        XCTAssertTrue(sut.nodesInSubview.count == maxStep)
    }
    
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
