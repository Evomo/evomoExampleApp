//
//  ViewController.swift
//  iPhoneOnlyExample
//
//  Created by Jakob Wowy on 18.03.20.
//  Copyright © 2020 Evomo UG. All rights reserved.
//

import UIKit
import EvomoMotionAI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        // Handle/Subscribe results
        ClassificationControlLayer.shared.elementalMovementHandler = { elementalMovement in
            // Will be executed every time a elementalMovement was classified
            let gameEvent: String?
            switch(elementalMovement.typeLabel) {
            case "hop_group_up":
                gameEvent = "jump"
            case "duck down":
                gameEvent = "duck"
            case "side_step_left":
                gameEvent = "left"
            case "side_step_right":
                gameEvent = "right"
            default:
                gameEvent = nil
            }
            
            // "duck down" = "Ducken Runter";
            // "duck up" = "Ducken Hoch";
            // "hop_group_up" = "Hop";
            // "side_step_left" = "Schritt nach Links";
            // "side_step_right" = "Schritt nach Rechts";
            // "turn_90_left" = "90° Drehung nach Links";
            // "turn_90_right" = "90° Drehung nach Rechts";
            
            if gameEvent != nil {
                print(gameEvent!)
            }
        }
        
        // Define device
        let deviceIphone = Device(deviceID: "", deviceType: .iPhone,
                                  devicePosition: .hand, deviceOrientation: .buttonDown)
        print("Start classification")
        // Start
        ClassificationControlLayer.shared.start(
            devices: [deviceIphone],
            licenseID: "4b3d051f-d4f5-46a6-a403-6f4a4b474dbd---",
            isStarted: {print("Startead!")},
            isFailed: {error in print("\(error)")}
            )
        
        sleep(10)
        
        // Stop
        _ = ClassificationControlLayer.shared.stop()
    }


}

