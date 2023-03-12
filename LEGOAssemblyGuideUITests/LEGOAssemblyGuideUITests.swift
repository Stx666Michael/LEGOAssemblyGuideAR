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

    func testElementExistence() throws {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertTrue(app.staticTexts["Please scan marker to start"].exists)
        XCTAssertTrue(app.staticTexts["Surface"].exists)
        XCTAssertTrue(app.staticTexts["Wireframe"].exists)
        XCTAssertTrue(app.staticTexts["Hand Occlusion"].exists)
        XCTAssertTrue(app.staticTexts["Previous"].exists)
        XCTAssertTrue(app.staticTexts["Preview"].exists)
        XCTAssertTrue(app.staticTexts["Auto Step"].exists)
        
        XCTAssertTrue(app.switches["Surface"].exists)
        XCTAssertTrue(app.switches["Wireframe"].exists)
        XCTAssertTrue(app.switches["Hand"].exists)
        XCTAssertTrue(app.switches["Previous"].exists)
        XCTAssertTrue(app.switches["Preview"].exists)
        XCTAssertTrue(app.switches["Autostep"].exists)
        
        XCTAssertTrue(app.otherElements["AR Scene View"].exists)
        XCTAssertTrue(app.otherElements["Sub Scene View"].exists)
        XCTAssertTrue(app.otherElements["Functional View"].exists)
    }
    
    func testScreenTap() throws {
        let arView = app.otherElements["AR Scene View"]
        var step = app.staticTexts["Step: 1 / 467"]
        XCTAssertTrue(step.waitForExistence(timeout: 20))
        
        for i in 2...4 {
            arView.tap()
            step = app.staticTexts["Step: " + String(i) + " / 467"]
            XCTAssertTrue(step.exists)
        }
        
        for i in 1...3 {
            arView.twoFingerTap()
            step = app.staticTexts["Step: " + String(4-i) + " / 467"]
            XCTAssertTrue(step.exists)
        }
        
        arView.twoFingerTap()
        step = app.staticTexts["Step: 1 / 467"]
        XCTAssertTrue(step.exists)
    }

}
