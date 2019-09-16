//
//  DeviceScanViewController.swift
//  evomoExampleApp
//
//  Created by Jakob Wowy on 08.09.19.
//  Copyright © 2019 Evomo UG. All rights reserved.
//

import UIKit
import EVORecording
import PromiseKit
import EVOFoundation

protocol ScanForMovesenseViewControllerDelegate : NSObjectProtocol{
    func setDevice(device: Device)
}

class ScanForMovesenseViewController: UITableViewController {
    weak var delegate : ScanForMovesenseViewControllerDelegate?
    
    let movesense = MovesenseService.shared
    
    private var bleOnOff = false
    
    let artificialWorkouts = WorkoutFile.describeAll()
    
    let sections = ["Mobile phone", "Artificial", "Movesense"]
    
    var device: Device?
    
    var bleDevices: [String] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func updateBleStatus(bleOnOff: Bool) {
        self.bleOnOff = bleOnOff
        
        self.bleDevices = [bleOnOff ? "Pull down to start scanning" : "Enable BLE"]
        
        self.tableView.separatorStyle = .none
        
        if !bleOnOff {
            self.refreshControl!.endRefreshing()
        }
        
        self.tableView.reloadData()
    }
    
    private func scanEnded() {
        self.refreshControl!.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let movesenseCount =  self.bleDevices.count
        let artificalCount = artificialWorkouts.count
        return [1, artificalCount, movesenseCount][section]
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
         return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        let label: String
        if section == 0 {
            label = UIDevice.current.name
        } else if section == 1 {
            label = artificialWorkouts[indexPath.row]
        } else {
            label = self.bleDevices[indexPath.row]
        }
        
        cell.textLabel?.text = label
        
        if ["Pull down to start scanning", "Enable BLE"].contains(label) {
            cell.textLabel?.textColor = .red
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.movesense.stopScan()
        self.refreshControl!.endRefreshing()
        let device: Device
        
        if indexPath.section == 0 {
            // iphone
            device = Device(deviceID: UIDevice.current.name, deviceType: .iPhone,
                            devicePosition: .belly, deviceOrientation: .buttonRight)
        } else if indexPath.section == 1 {
            // artificial
            device = Device(deviceID: artificialWorkouts[indexPath.row], deviceType: .artificial,
                            devicePosition: .belly, deviceOrientation: .buttonRight)
        } else {
            // movesense
            var indexPath = self.tableView.indexPathForSelectedRow!
            let bleDeviceID = self.bleDevices[indexPath.row]
            
            if ["Pull down to start scanning", "Enable BLE"].contains(bleDeviceID) {
                return
            }
            
            device = Device(deviceID: bleDeviceID, deviceType: .movesense,
                            devicePosition: .belly, deviceOrientation: .buttonRight,
                            heartRate: true)
            

        }
        
        // segue back to classification view
        if let delegate = delegate{
            delegate.setDevice(device: device)
        }
        navigationController!.popViewController(animated: true)
        
    }
    
    @objc func startScan() {
        if self.bleOnOff {
            self.bleDevices = []
            
            firstly {
                when(resolved: self.movesense.startScan({ _ in
                    // device found
                    self.bleDevices = self.movesense.getDevices().map { $0.serial }
                    self.tableView.reloadData() }))
                }.done {_ in
                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
            }
        } else {
            self.refreshControl!.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = UIColor(red: 0.93, green: 0.19, blue: 0.14, alpha: 1.0)
        self.refreshControl!.tintColor = UIColor.white
        self.refreshControl!.addTarget(self, action: #selector(self.startScan), for: .valueChanged)
        
        self.movesense.setHandlers(
            deviceConnected: { _ in
                self.tableView.reloadData()
        },
            deviceDisconnected: { _ in
                self.tableView.reloadData()
        },
            bleOnOff: { (state) in
                self.updateBleStatus(bleOnOff: state)
        })
        
    }
}
