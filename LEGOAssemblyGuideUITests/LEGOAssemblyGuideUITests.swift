//
//  LEGOAssemblyGuideUITests.swift
//  LEGOAssemblyGuideUITests
//
//  Created by Tianxiang Song on 05/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import XCTest

final class LEGOAssemblyGuideUITests: XCTestCase {

    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLabelText() throws {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let step = app.staticTexts["Please scan marker to start"]
        let surface = app.staticTexts["Surface"]
        let wireframe = app.staticTexts["Wireframe"]
        let hand = app.staticTexts["Hand Occlusion"]
        let previous = app.staticTexts["Previous"]
        let preview = app.staticTexts["Preview"]
        let auto = app.staticTexts["Auto Step"]
        
        XCTAssertTrue(step.exists)
        XCTAssertTrue(surface.exists)
        XCTAssertTrue(wireframe.exists)
        XCTAssertTrue(hand.exists)
        XCTAssertTrue(previous.exists)
        XCTAssertTrue(preview.exists)
        XCTAssertTrue(auto.exists)
    }

}
