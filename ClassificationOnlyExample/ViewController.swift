//
//  ViewController.swift
//  ClassificationOnlyExample
//
//  Created by Jakob Wowy on 15.02.20.
//  Copyright © 2020 Evomo UG. All rights reserved.
//

import UIKit
import EvomoMotionAI
import PromiseKit

class ViewController: UIViewController {
    var classification: Classification?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // setup device - for classification only postion, orientation and forward is relevant
        let device = Device(deviceID: "", deviceType: .iPhone, devicePosition: .machineWeight, deviceOrientation: .buttonRight, deviceForward: true)
        
        do {
            // init class
            if classification == nil {
                classification = try Classification(device: device)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        if let classificationInstance = classification {
            
            // Handle subscripted classified movements
            classificationInstance.subscribe(with: ObjectIdentifier(self)) { movement in
                print(movement!.typeLabel)
            }
            
            firstly {
                // start classification
                classificationInstance.startClassification(licenseID: licenseID)
            }.done { _ in
                print("Classification started")
            }.catch { error in
                print("Error on startingClassification: \(error.localizedDescription)")
            }
            
            // feed measurement points - single mp oder as array
            do {
            try classificationInstance.add([(AccelerationData(x: 1, y: 2, z: 3),
                                        RotationRateData(x: 1, y: 2, z: 3),
                                        GravityData(x: 1, y: 2, z: 3),
                                        UserAccelerationData(x: 1, y: 2, z: 3),
                                        QuaternionData(x: 1, y: 2, z: 3, w: 4),
                                        Date())], device: device)
            } catch {
                print("Error adding mps: \(error.localizedDescription)")
            }
            
            // unsubscripe at end of the workout
            classificationInstance.unsubscribe(with: ObjectIdentifier(self))
            
        }
        
    }
    
}
