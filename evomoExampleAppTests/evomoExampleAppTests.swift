//
//  evomoExampleAppTests.swift
//  evomoExampleAppTests
//
//  Created by Jakob Wowy on 14.02.20.
//  Copyright © 2020 Evomo UG. All rights reserved.
//

import XCTest
import EvomoMotionAI

class evomoExampleAppTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            ClassificationControlLayer.shared.setLicense(licenseID: licenseID)
            let mTypes = ClassificationControlLayer.shared.getAvailibleMovements(device: Device.defaultValue())
            XCTAssertTrue(mTypes.count > 0)
        }
    }

}
