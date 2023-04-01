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
        for _ in 1...200 {sut.oneTapGestureFired()}
        
    }

}
