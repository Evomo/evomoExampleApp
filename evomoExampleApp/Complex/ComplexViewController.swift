//
//  ViewController.swift
//  evomoExampleApp
//
//  Created by Jakob Wowy on 28.02.19.
//  Copyright © 2019 Evomo UG. All rights reserved.
//

import UIKit
import EVOFoundation
import EVOControlLayer
import PromiseKit
import EVORecording
import SwiftSpinner

class ComplexViewController: UIViewController, ScanForMovesenseViewControllerDelegate {
    
    
    @IBOutlet weak var deviceType: UITextField!
    @IBOutlet weak var deviceID: UITextField!
    @IBOutlet weak var movementsLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UITextField!
    
    var iMovement: Int = 0
    var devices: [Device] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add licenseID string once
        ClassificationControlLayer.shared.setLicense(licenseID: licenseID)
        
        // Handle subscription of the classified movements
        ClassificationControlLayer.shared.movementHandler = { movement in
            // Will be executed every time a movement was classified
            self.iMovement += 1
            DispatchQueue.main.async {
                self.addLabelLine("\(self.iMovement). \(movement.typeLabel)")
            }
        }
        
        // Handle subscription of the heart rate changes
        ClassificationControlLayer.shared.heartRateSubHandler = { (heartRate, _) in
            // Will be executed every time the heart rate value changes
           
            DispatchQueue.main.async {
                self.heartRateLabel.text = "\(heartRate) BPM"
            }
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
        
        // Styling
        movementsLabel.numberOfLines = 0
        movementsLabel.text = ""
        
        movementsLabel.layer.borderWidth = 2
        movementsLabel.layer.borderColor = UIColor.lightGray.cgColor

    }
    
    // MARK: Device scan
    // Set scaned device via delegation
    func setDevice(device: Device) {
        self.devices = [device]
        deviceType.text = device.deviceType.rawValue
        deviceID.text = device.deviceID
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ScanDevice"){
            let deviceScanVC = segue.destination as! ScanForMovesenseViewController
            deviceScanVC.delegate = self
            
        }
    }
    
    @IBAction func ScanForDevice(_ sender: Any) {
        performSegue(withIdentifier: "ScanDevice", sender: self)
    }
    
    
    // MARK: Start classification
    @IBAction func startClassification(_ sender: UIButton) {
       
        DispatchQueue.main.async {
            self.addLabelLine("--- Start Classification ---")
            
            // Start connection spinner
            SwiftSpinner.show("Connecting ...")
        }
        self.iMovement = 0
        
        // Start movement classification
        
        ClassificationControlLayer.shared.start(
            devices: self.devices,
            isConnected: {
                self.addLabelLine("--- All devices connected ---")
        }, isStarted:{
            self.addLabelLine("--- All devices started ---")
            // Hide Spinner if device is connected
            DispatchQueue.main.async {
                SwiftSpinner.hide()
            }
        }, isFailed: { error in
            
            // Failure Message by Spinner
            DispatchQueue.main.async {
                SwiftSpinner.show("Error", animated: false)
                    .addTapHandler({SwiftSpinner.hide()},
                                   subtitle: self.parseErrorMessage(error))
                
            }
        })
    }

    @IBAction func stopClassification(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.addLabelLine("--- Stop Classification ---")
        }
        // Stop movement classification
        _ = ClassificationControlLayer.shared.stop()
    }
    
    @IBAction func onClick(_ sender: UIButton) {
        self.view.endEditing(true)
    }
    
    func addLabelLine(_ lineString: String, addAfter: Bool = false) {
        DispatchQueue.main.async {
            if addAfter {
                self.movementsLabel.text = String(self.movementsLabel.text!) + lineString + "\n"
            } else {
                self.movementsLabel.text = lineString + "\n" + String(self.movementsLabel.text!)
            }
        }
    }
    
    func parseErrorMessage(_ error: Error) -> String {
        // extract message from error object
        let message: String
        if case EMGeneralErrors.devicesNotFound(let description) = error {
            message = "\(description)"
            
        } else if case EMGeneralErrors.errorDescription(let description) = error {
            message = "\(description)"
        } else {
            message = "\(error)"
        }
        return message
    }
}
