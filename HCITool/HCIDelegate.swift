//
//  HCIDelegate.swift
//  HCITool
//
//  Created by Alsey Coleman Miller on 6/17/18.
//  Copyright © 2018 Pure Swift. All rights reserved.
//

import Foundation
import IOBluetooth
import IOKit

@objc class HCIDelegate: NSObject {
    
    
}

extension HCIDelegate: IOBluetoothHostControllerDelegate {
    
    @objc(controllerHCIEvent:message:)
    func controllerHCIEvent(_ controller: IOBluetoothHostController, message: CUnsignedInt) {
        
        print(#function, message)
    }
    
    @objc(controllerNotification:message:)
    func controllerNotification(_ controller: IOBluetoothHostController, message: CUnsignedInt) {
        
        print(#function, message)
    }
    
    @objc(BluetoothHCIEventNotificationMessage:inNotificationMessage:)
    public func bluetoothHCIEventNotificationMessage(_ controller: IOBluetoothHostController,
                                                     in message: UnsafeMutablePointer<IOBluetoothHCIEventNotificationMessage>) {
        
        print(#function)
        
        let opcode = message.pointee.dataInfo.opcode
        
        let data = IOBluetoothHCIEventParameterData(message)
        
        print("HCI Event \(opcode):", data)
    }
}
