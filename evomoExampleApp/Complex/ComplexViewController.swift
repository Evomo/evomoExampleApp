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

        // Handle subscription of the classified movements
        ClassificationControlLayer.shared.movementHandler = { movement in
            // Will be executed every time a movement was classified
            self.iMovement += 1
            DispatchQueue.main.async {
                self.addLabelLine("\(self.iMovement). \(movement.label)")
            }
        }
        
        // Handle subscription of the heart rate changes
        ClassificationControlLayer.shared.heartRateSubHandler = { (heartRate, _) in
            // Will be executed every time the heart rate value changes
           
            DispatchQueue.main.async {
                self.heartRateLabel.text = "\(heartRate) BPM"
            }
        }
        
        // Styling
        movementsLabel.numberOfLines = 0
        movementsLabel.text = ""
        
        movementsLabel.layer.borderWidth = 2
        movementsLabel.layer.borderColor = UIColor.secondaryLabel.cgColor

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
            lookingForMovementType: nil,
            isConnected: {
                // Hide Spinner if device is connected
                DispatchQueue.main.async {
                    SwiftSpinner.hide()
                }
        }, connectingFailed: { error in
            
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
    
    @IBAction func classifyPosition(_ sender: UIButton) {
        
        self.movementsLabel.text = String("--- Classify Sensor Position ---")
        // Show spinner
        SwiftSpinner.show("Connecting ...")
        
        ClassificationControlLayer.shared.startPositionClassificationWithTimeout(
            device: self.devices[0],
            timeoutSeconds: 5,
            isConnected: {
                // Hide Spinner if device is connected
                DispatchQueue.main.async {
                    SwiftSpinner.hide()
                }
        }, connectingFailed: { error in
            // Failure Message by Spinner
            DispatchQueue.main.async {
                SwiftSpinner.show("Error", animated: false)
                    .addTapHandler({SwiftSpinner.hide()},
                                   subtitle: self.parseErrorMessage(error))
                
            }
        }).done { stats in
            
            self.addLabelLine("--- Classification finished! ---"
                + "\nResults: "
                + "\nPosition: \(stats.0)"
                + "\nOrientation: \(stats.1)"
                + "\n--- ---"
                + "\n\(stats.2)"
                + "\n--- ---", addAfter: true)
            }.catch { error in
                self.addLabelLine("--- Classification failed: \(error)")
        }
    
        
        
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
