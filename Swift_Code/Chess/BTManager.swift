//
//  BTManager.swift
//  ChessApp
//
//  Created by Sasha Ohayon on 2020-08-26.
//  Copyright © 2020 Ethan Ohayon. All rights reserved.
//

import UIKit
import CoreBluetooth

let GOOD_MOVE_CODE = Data([0])
let ERROR_CODE = Data([1])
let SEND_BOARD_STATE_CODE = Data([2])

class BTManager: UIViewController {
    
    static let shared = BTManager()
        
    var manager: CBCentralManager?
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic!

    func setPeripheral(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    func getPeripheral() -> CBPeripheral? {
        return self.peripheral
    }
    func setCentral(_ manager: CBCentralManager) {
        self.manager = manager
    }
    
    func setCharacteristic(_ characteristic: CBCharacteristic) {
        self.characteristic = characteristic
    }
    
    func getCharacteristic() -> CBCharacteristic? {
        return self.characteristic
    }
    
    func connect() {
        manager?.connect(peripheral!)
    }
    
    func stopScan() {
        manager?.stopScan()
    }
    
    func setPeripheralDelegate(_ delegate: CBPeripheralDelegate) {
        peripheral?.delegate = delegate
    }
    
    func scan() {
        manager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        peripheral?.discoverServices(serviceUUIDs)
    }
    
    func sendMessage(_ data: Data, _ char: CBCharacteristic, _ writeType: CBCharacteristicWriteType) {
        
        peripheral?.writeValue(data, for: char, type: writeType)
    }
    
    
}
