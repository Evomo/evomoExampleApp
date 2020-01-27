//
//  ViewController.swift
//  evomoExampleApp
//
//  Created by Jakob Wowy on 28.02.19.
//  Copyright © 2019 Evomo UG. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftSpinner
import EvomoMotionAI

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
            
            let deviceEventLogString = handleDeviceEvents(deviceEvent: deviceEvent)
            self.addLabelLine(deviceEventLogString)
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
            SwiftSpinner.show("1. Connecting ...")
        }
        self.iMovement = 0
        
        // Start movement classification
        
        ClassificationControlLayer.shared.start(
            devices: self.devices,
            isConnected: {
                DispatchQueue.main.async {
                    SwiftSpinner.show("2. Starting ...")
                }
                self.addLabelLine("--- All devices connected ---")
        }, isStarted:{
            self.addLabelLine("--- All devices started ---")
            // Hide Spinner if device is connected
            DispatchQueue.main.async {
                SwiftSpinner.show(duration: 0.3, title: "Done")
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
