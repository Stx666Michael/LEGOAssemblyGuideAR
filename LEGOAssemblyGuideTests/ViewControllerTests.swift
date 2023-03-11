//
//  ViewControllerTests.swift
//  LEGOAssemblyGuideTests
//
//  Created by Tianxiang Song on 12/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import XCTest
import ARKit
@testable import LEGOAssemblyGuide

final class ViewControllerTests: XCTestCase {

    var sut: ViewController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testViewDidLoad() throws {
        XCTAssertNotNil(sut.sceneView, "ARSCNView should not be nil")
        XCTAssertTrue(sut.sceneView.delegate === sut, "Scene View delegate must be set to the view controller instance")
        XCTAssertNotEqual(sut.sceneView.debugOptions, ARSCNDebugOptions.showWireframe, "AR scene view debug options must not set to show wireframe")
    }

}
