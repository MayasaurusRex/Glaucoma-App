//
//  BLE_Peripheral.swift
//  Glaucoma_App
//
//  Created by Maya Hegde on 12/19/23.
//

import Foundation
import CoreBluetooth

class BlePeripheral {
 static var connectedPeripheral: CBPeripheral?
 static var connectedService: CBService?
 static var connectedTXChar: CBCharacteristic?
 static var connectedRXChar: CBCharacteristic?
}
