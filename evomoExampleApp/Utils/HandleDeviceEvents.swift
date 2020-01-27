//
//  HandleDeviceEvents.swift
//  evomoExampleApp
//
//  Created by Jakob Wowy on 15.12.19.
//  Copyright © 2019 Evomo UG. All rights reserved.
//

import Foundation
import EvomoMotionAI

func handleDeviceEvents(deviceEvent: DeviceEvent) -> String {
    let (device, event) = deviceEvent
    
    // Build device string
    let deviceString: String
    if device.deviceType == .movesense {
        deviceString = "MS-\(String(Array(device.deviceID.reversed())[...3].reversed()))"
    } else {
        
        deviceString = "\(device.deviceType)"
    }
    let logString: String
    
    switch event {
    case let .dataStraming(state):
        // Will be triggered on data streaming state change (Bloool)
        // dataStraming = true if sensor data received in the last 0.2 seconds
        
        logString = "\(deviceString): \(state ? "data streaming" : "data stream lost")"
        
    case let .connected(connected):
        // Will be triggered if the device successfully connect or disconnect
        
        logString = "\(deviceString): \(connected ? "connected" : "disconnected")"
        
    case let .energyPercent(energyPercent):
        // Implemented for movesense devices (Apple devices dont return a energy level)
        // The energy level will always emit on after connecting to the device.
        logString = "\(deviceString): Energy \(Int(energyPercent * 100)) %"
        
    case let .softwareVersion(version):
        // not implemented now
        // Will return the software version of the device after connecting
        logString = "\(deviceString): OS/FW - \(version)"

    @unknown default:
        logString = "unknown device event case"
    }
    return logString
}
