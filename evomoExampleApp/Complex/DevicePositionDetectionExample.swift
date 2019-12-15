//
//  PostureDetectionExample.swift
//  evomoExampleApp
//
//  Created by Jakob Wowy on 13.12.19.
//  Copyright © 2019 Evomo UG. All rights reserved.
//

//import Foundation
//
//@IBAction func classifyPosition(_ sender: UIButton) {
//
//    self.movementsLabel.text = String("--- Classify Sensor Position ---")
//    // Show spinner
//    SwiftSpinner.show("Connecting ...")
//
//    ClassificationControlLayer.shared.startPositionClassificationWithTimeout(
//        device: self.devices[0],
//        timeoutSeconds: 5,
//        isConnected: {
//            // Hide Spinner if device is connected
//            DispatchQueue.main.async {
//                SwiftSpinner.hide()
//            }
//    }, connectingFailed: { error in
//        // Failure Message by Spinner
//        DispatchQueue.main.async {
//            SwiftSpinner.show("Error", animated: false)
//                .addTapHandler({SwiftSpinner.hide()},
//                               subtitle: self.parseErrorMessage(error))
//
//        }
//    }).done { stats in
//
//        self.addLabelLine("--- Classification finished! ---"
//            + "\nResults: "
//            + "\nPosition: \(stats.0)"
//            + "\nOrientation: \(stats.1)"
//            + "\n--- ---"
//            + "\n\(stats.2)"
//            + "\n--- ---", addAfter: true)
//        }.catch { error in
//            self.addLabelLine("--- Classification failed: \(error)")
//    }
//}
