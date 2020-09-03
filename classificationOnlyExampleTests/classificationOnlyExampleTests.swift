//
//  classificationOnlyExampleTests.swift
//  classificationOnlyExampleTests
//
//  Created by Jakob Wowy on 03.09.20.
//  Copyright © 2020 Evomo UG. All rights reserved.
//

import XCTest
import EVOClassification
import PromiseKit

class classificationOnlyExampleTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func basicClassificationTest() throws {
        
        // setup device - for classification only postion, orientation and forward is relevant
        let device = Device(deviceID: "", deviceType: .iPhone, devicePosition: .machineWeight, deviceOrientation: .buttonRight, deviceForward: true)
        
        // init class
        
        let classification = Classification(device: device, licenseID: licenseID)
        
        // Handle subscripted classified movements
        classification.subscribeMovements(with: ObjectIdentifier(self)) { movement in
            print(movement!.typeLabel)
        }
        
        firstly {
            // start classification
            classification.startClassification()
        }.done { _ in
            print("Classification started")
        }.catch { error in
            print("Error on startingClassification: \(error.localizedDescription)")
        }
        
        // feed measurement points - single mp oder as array
        do {
            try classification.add([(AccelerationData(x: 1, y: 2, z: 3),
                                             RotationRateData(x: 1, y: 2, z: 3),
                                             GravityData(x: 1, y: 2, z: 3),
                                             MagneticFieldData(x: 1, y: 2, z: 3),
                                             QuaternionData(x: 1, y: 2, z: 3, w: 4),
                                             Date())], device: device)
        } catch {
            print("Error adding mps: \(error.localizedDescription)")
        }
        
        // unsubscripe at end of the workout
        classification.unsubscribeAll(with: ObjectIdentifier(self))
        
    }
    
}
