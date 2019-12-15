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
            deviceType: .iPhone,
            isSimulated: true,
            devicePosition: .belly, // <- do not change for artificial
            deviceOrientation: .buttonRight)
            //            ,
            //                   Device(deviceID: WorkoutFile.squats.rawValue, // options: .jumpingJacks, .squats, .sixerSets, .running
            //                    deviceType: .artificial,
            //                    devicePosition: .belly, // <- do not change for artificial
            //                    deviceOrientation: .buttonRight)
        ]// <- do not change for artificial
        
        #else
        devices = [Device(deviceID: "", deviceType: .iPhone, isSimulated: false, devicePosition: .belly, deviceOrientation: .buttonRight)]
        #endif
        
        // Declare licenseID string once (You will receive the license key from Evomo after agreeing to the license conditions.)
        ClassificationControlLayer.shared.setLicense(licenseID: licenseID)
        
        // Handle heart rate changes
        ClassificationControlLayer.shared.heartRateSubHandler = { (hr, _) in
            // Will not triggered on iPhone only (only for movesense devices)
            print("New HeartRate: \(hr)")
        }
        
        // Handle subscription of the classified movements
        ClassificationControlLayer.shared.movementHandler = { movement in
            // Will be executed every time a movement was classified
            self.iMovement += 1
            self.addLabelLine(String("\(self.iMovement). \(movement.typeLabel)"))
        }
        
        // Handle device events
        ClassificationControlLayer.shared.deviceEventHandler = { deviceEvent in
            let (device, event) = deviceEvent
            
            switch event {
            case let .dataStraming(state):
                // Will be triggered on data streaming state change (Bool)
                // dataStraming = true if sensor data received in the last 0.2 seconds
 
                self.addLabelLine("\(device.deviceType): \(state ? "data streaming" : "data stream lost")")
                
            case let .connected(connected):
                // Will be triggered if the device successfully connect or disconnect
                
                self.addLabelLine("\(device.deviceType): \(connected ? "connected" : "disconnected")")
                
            case let .energyPercent(energyPercent):
                // Implemented for movesense devices (Apple devices dont return a energy level)
                // The energy level will always emit on after connecting to the device.
                self.addLabelLine("\(device.deviceType): EnergyLevel \(energyPercent * 100) %")
                
            case let .softwareVersion(version):
                // not implemented now
                // Will return the software version of the device after connecting
                self.addLabelLine("\(device.deviceType): OS - \(version)")
            }
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
