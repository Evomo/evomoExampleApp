//
//  SimpleViewController.swift
//  evomoExampleApp
//
//  Created by Jakob Wowy on 09.09.19.
//  Copyright © 2019 Evomo UG. All rights reserved.
//

import Foundation
import UIKit
import EvomoMotionAIMovesense

class SimpleViewController: UIViewController {
    
    @IBOutlet weak var movementsLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    
    var iMovement: Int = 0
    var started: Bool = false
    var devices: [Device] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(simulator)
        self.devices = [
            Device(deviceID: "simulatedIphone",
                   deviceType: .iPhone,
                   devicePosition: .belly, // <- do not change for artificial
                deviceOrientation: .buttonRight,
                isSimulated: true,
                details: "jumpingJack") // options: .jumpingJacks, .squats, .sixerSets, .running
        ]
        
        #else
        self.devices = [Device(deviceID: "", deviceType: .iPhone, devicePosition: .belly, deviceOrientation: .buttonRight)]
        #endif
        
        // Declare licenseID string once (You will receive the license key from Evomo after agreeing to the license conditions.)
        ClassificationControlLayer.shared.setLicense(licenseID: licenseID)
        
        // Handle subscription of the classified movements
        ClassificationControlLayer.shared.movementHandler = { movement in
            // Will be executed every time a movement was classified
            self.iMovement += 1
            self.addLabelLine(String("\(self.iMovement). \(movement.typeLabel)"))
        }
        

        // Handle device events
        ClassificationControlLayer.shared.deviceEventHandler = { deviceEvent in
            
            let deviceEventLogString = handleDeviceEvents(deviceEvent: deviceEvent)
            self.addLabelLine(deviceEventLogString)
        }
        
        // Styleing
        movementsLabel.numberOfLines = 0
        movementsLabel.text = ""
        
        movementsLabel.layer.borderWidth = 2
        movementsLabel.layer.borderColor = UIColor.lightGray.cgColor
        
        startStopButton.setTitle("Start Classification" , for: .normal)
    }
    
    
    @IBAction func startStopAction(_ sender: Any) {
        if started {
            
            self.addLabelLine("--- Stop Classification ---")
            
            // Stop movement classification
            _ = ClassificationControlLayer.shared.stop()
            startStopButton.setTitle("Start Classification" , for: .normal)
            self.started = false
            
        } else {
                        
            self.addLabelLine("--- Start Classification ---")
            self.iMovement = 0
            
            DispatchQueue.global().async {
                
                // Start movement classification
                ClassificationControlLayer.shared.start(
                    devices: self.devices,
                    isConnected: {
                        self.addLabelLine("--- All devices connected ---")
                        self.started = true
                }, isStarted:{
                    self.addLabelLine("--- All devices started ---")
                }, isFailed: { error in
                    
                    self.addLabelLine("Start classification failed: \(error)")
                    self.startStopButton.setTitle("Stop Classification" , for: .normal)
                    
                    self.started = false
                    self.startStopButton.setTitle("Start Classification" , for: .normal)
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
