//
//  evomoExampleAppTests.swift
//  evomoExampleAppTests
//
//  Created by Jakob Wowy on 03.09.20.
//  Copyright © 2020 Evomo UG. All rights reserved.
//

import XCTest
import EvomoMotionAI
import PromiseKit

class evomoExampleAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func basicClassificationTest() throws {
        let expectation = self.expectation(description: #function)
        // Init the ClassificationControlLayer

        // Declare licenseID string once (You will receive the license key from Evomo after agreeing to the license conditions.)
        ClassificationControlLayer.shared.setLicense(licenseID: licenseID)
        
        ClassificationControlLayer.shared.debugging = true
        ClassificationControlLayer.shared.gaming = true
        
        ClassificationControlLayer.shared.setupLogging(logLevel: .debug)
        
        // Define sensor device
        let devices = [Device(deviceID: "",
                              deviceType: .iPhone,
                              devicePosition: .hand,
                              deviceOrientation: .buttonDown,
                              isSimulated: true,
                              classificationModel: "2129",
                              details: "gaming_movements")] // 2115
        
        var movements: [Movement] = []
        // Subscribe to the classified movements
        ClassificationControlLayer.shared.movementHandler = { movement in
            print(movement.typeLabel)
            movements.append(movement)
        }
        
        ClassificationControlLayer.shared.elementalMovementHandler =  { elmo in
            print("Elmo - \((elmo.typeLabel, elmo.duration, elmo.start.timeIntervalSince1970, elmo.end.timeIntervalSince1970))")
            
        }
        
        ClassificationControlLayer.shared.deviceEventHandler = { event in
            print("event", event)
        }
                
        // Start movement classification
        ClassificationControlLayer.shared.start(
            devices: devices,
            isConnected: {
                print("--- All devices connected ---")
        }, isStarted:{
            print("--- All devices started ---")
        }, isFailed: { error in
            print("Start classification failed: \(error)")
            XCTAssertTrue(false)
        })
        
        after(.seconds(5)).done{

            // Stop movement classification
            _ = ClassificationControlLayer.shared.stop().done { _ in
                ClassificationControlLayer.shared.start(
                    devices: devices,
                    isConnected: {
                        print("--- All devices connected ---")
                }, isStarted:{
                    print("--- All devices started ---")
                }, isFailed: { error in
                    print("Start classification failed: \(error)")
                    XCTAssertTrue(false)
                })
                after(.seconds(5)).done{

                    // Stop movement classification
                    _ = ClassificationControlLayer.shared.stop()
                }.done{
                    expectation.fulfill()
                    XCTAssertTrue(movements.count >= 3)
                }
            }
        }
        
        waitForExpectations(timeout: 15)
    }

}
