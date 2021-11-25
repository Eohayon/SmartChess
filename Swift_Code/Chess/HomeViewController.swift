//
//  HomeViewController.swift
//  ChessApp
//
//  Created by Ethan Ohayon on 2020-08-24.
//  Copyright © 2020 Ethan Ohayon. All rights reserved.
//

import UIKit
import CoreBluetooth

class HomeViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var statusText: UILabel!

    private var manager = BTManager.shared
    private var initBoardState = [[Int]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.setPeripheralDelegate(self)
        
        if manager.getPeripheral() == nil {
            manager.setCentral(CBCentralManager(delegate: self, queue: nil))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.boardStates[0] = initBoardState
        }
    }
    
    @IBAction func startPressed(sender: UIButton) {
        manager.sendMessage(SEND_BOARD_STATE_CODE, manager.getCharacteristic()!, .withoutResponse)

        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.navigationController!.view.layer.add(transition, forKey: nil)
        let writeView : ViewController = self.storyboard?.instantiateViewController(withIdentifier: "VC") as! ViewController
        self.navigationController?.pushViewController(writeView, animated: false)
    }
}

extension HomeViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
//onStateChange
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
              case .unknown:
                print("central.state is .unknown")
              case .resetting:
                print("central.state is .resetting")
              case .unsupported:
                print("central.state is .unsupported")
              case .unauthorized:
                print("central.state is .unauthorized")
              case .poweredOff:
                print("central.state is .poweredOff")
              case .poweredOn:
                print("central.state is .poweredOn")
                manager.scan()
            @unknown default:
                break
        }
    }
        
//onDevicesDiscovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any],rssi RSSI: NSNumber) {
        if peripheral.name == "SmartChess" {
            print("\nDevice Name: ", peripheral.name!)
            print("UUID", peripheral.identifier)
            manager.setPeripheral(peripheral)
            manager.setPeripheralDelegate(self)
            manager.stopScan()
            manager.connect()
        }
    }
    
//onConnect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        DispatchQueue.main.async() {
            self.statusText.text = "Status: Connected"
            self.view.setNeedsDisplay()
            self.statusText.setNeedsDisplay()
        }
        
        print("\nDevice Connected\n")
        manager.discoverServices(nil)
    }
    
//onDisconnect
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async() {
            self.statusText.text = "Status: Disconnected"
            self.view.setNeedsDisplay()
            self.statusText.setNeedsDisplay()
        }
        
        manager.connect()

    }
    
//onCharacteristicsDiscovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
//onPropertiesDiscovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print(characteristic)
            manager.setCharacteristic(characteristic)
            if characteristic.properties.contains(.read) {
                print("\n\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify\n")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
//onMessageReceived
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let characteristicData = characteristic.value
        var byteArray = [UInt8](characteristicData!)
        var macAddress = [UInt8]()
        
        for byte in byteArray {
            if byteArray.count <= 6 {
                macAddress.append(byte)
                byteArray.removeFirst()
            } else {
                let num = (String(byte, radix: 2))
                let arr = num.utf8.map{Int(($0 as UInt8)) - 48}

                initBoardState.append(arr)
            }
        }
    }
}
