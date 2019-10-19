//
//  SimpleViewController.swift
//  evomoExampleApp
//
//  Created by Jakob Wowy on 09.09.19.
//  Copyright © 2019 Evomo UG. All rights reserved.
//

import Foundation
import UIKit
import EVOControlLayer
import EVOFoundation
import EVORecording

class SimpleViewController: UIViewController {
    
    @IBOutlet weak var movementsLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    
    var iMovement: Int = 0
    var started: Bool = false
    var devices: [Device] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        #if targetEnvironment(simulator)
        devices = [Device(deviceID: WorkoutFile.jumpingJacks.rawValue, // options: .jumpingJacks, .squats, .sixerSets, .running
                    deviceType: .artificial,
                    devicePosition: .belly, // <- do not change for artificial
                    deviceOrientation: .buttonRight),
                   Device(deviceID: WorkoutFile.squats.rawValue, // options: .jumpingJacks, .squats, .sixerSets, .running
                    deviceType: .artificial,
                    devicePosition: .belly, // <- do not change for artificial
                    deviceOrientation: .buttonRight)
        ]// <- do not change for artificial
        
        #else
        devices = [Device(deviceID: "", deviceType: .iPhone, devicePosition: .belly, deviceOrientation: .buttonRight)]
        #endif
        
        // Handle heart rate changes
        ClassificationControlLayer.shared.heartRateSubHandler = { (hr, _) in
            print("New HeartRate: \(hr)")
        }
        
        // Handle subscription of the classified movements
        ClassificationControlLayer.shared.movementHandler = { movement in
            // Will be executed every time a movement was classified
            self.iMovement += 1
            self.addLabelLine(String("\(self.iMovement). \(movement.label)"))
        }
        
        // Styleing
        movementsLabel.numberOfLines = 0
        movementsLabel.text = ""
        
        movementsLabel.layer.borderWidth = 2
        movementsLabel.layer.borderColor = UIColor.secondaryLabel.cgColor
        
        startStopButton.setTitle("Start Classification" , for: .normal)
    }
    
    
    @IBAction func startStopAction(_ sender: Any) {
        if started {
            
            self.addLabelLine("--- Stop Classification ---")
            
            // Stop movement classification
            _ = ClassificationControlLayer.shared.stop()
            startStopButton.setTitle("Start Classification" , for: .normal)
            self.started = true
            
        } else {
            self.addLabelLine("--- Start Classification ---")
            self.iMovement = 0
            
            DispatchQueue.global().async {
                
                // Start movement classification
                ClassificationControlLayer.shared.start(
                    devices: self.devices,
                    lookingForMovementType: nil,
                    isConnected: {
                        self.addLabelLine("Connected")
                        self.started = true
                }, connectingFailed: { error in

                    self.addLabelLine("Connection failed: \(error)")
                    self.startStopButton.setTitle("Stop Classification" , for: .normal)
                    
                    self.started = false
                })
            }
            self.startStopButton.setTitle("Stop Classification" , for: .normal)
        }
        
    }
    
    func addLabelLine(_ lineString: String) {
        DispatchQueue.main.async {
            
            self.movementsLabel.text = lineString + "\n" + String(self.movementsLabel.text!)
        }
    }
}
