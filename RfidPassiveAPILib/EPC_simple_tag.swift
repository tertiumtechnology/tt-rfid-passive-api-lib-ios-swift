//
//  EPC_simple_tag.swift
//  RfidPassiveAPILib
//
//  Created by Stefano Crosara on 01/08/24.
//  Copyright © 2024 Tertium. All rights reserved.
//

import Foundation

public class EPC_simple_tag: EPC_tag
{
    /// Class Constructor
    ///
    /// - parameter RSSI - the tag RSSI at inventory time (dBm)
    /// - parameter PC - the tag PC (Protocol Code)
    /// - parameter ID - the tag ID
    /// - parameter passiveReader - reference to the passive reader object
    init(RSSI: Int16, ID: [UInt8], passiveReader: PassiveReader) {
        super.init(RSSI: RSSI, PC: 0, ID: ID, passiveReader: passiveReader)
    }
    
    /// Get the tag ID
    ///
    /// - returns - the tag ID as byte array
    public override func getID() -> [UInt8] {
        var newID = [UInt8](repeating:0, count: ID.count)
        for n in 0..<ID.count {
            newID[n] = ID[n]
        }
        
        return newID
    }
    
    /// Start a tag kill operation.
    ///
    /// The result of the kill operation is notified invoking response listener method
    /// AbstractResponseListener.killEvent([UInt8], Int)
    ///
    /// - parameter password - tag kill password
    public override func kill(password: [UInt8]) {
        var params = [UInt8](repeating: 0, count: 3)
        var command: String
        
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.killEvent(tagID: getExtendedID(), error: AbstractResponseListener
                .READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if (password.count != 4) {
            passiveReader.responseListenerDelegate?.killEvent(tagID: getExtendedID(), error: AbstractResponseListener
                .READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        params[0] = UInt8(timeout / 100)
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.KILL_COMMAND
        passiveReader.tagID = getID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_KILL_COMMAND, parameters: params)
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: password)
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }
    
    /// Start a tag lock operation.
    ///
    /// The result of the lock operation is notified invoking response listener
    /// method AbstractResponseListener.lockEvent([UInt8], Int)
    ///
    /// - parameter lock_type -    the lock type
    /// - parameter password -     tag access password (may be null or empty)
    public override func lock(lock_type: Int, password: [UInt8]?) {
        var payload = [UInt8](repeating: 0, count: 3)
        var timeOutData = [UInt8](repeating: 0, count: 1)
        var command: String
        
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.lockEvent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        let tmp = String(format: "%06X", lock_type)
        payload[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        payload[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        payload[2] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 4, end: 6)))
        timeOutData[0] = UInt8(timeout / 100)
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.LOCK_COMMAND
        passiveReader.tagID = getID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_LOCK_COMMAND, parameters: timeOutData)
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: payload)
        if (password != nil) {
            command = passiveReader.appendDataToCommand(command: command, data: password!)
        }
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }
    
    /// Start a tag memory read operation.
    ///
    /// The result of the read operation is notified invoking response listener method
    /// AbstractResponseListener.readEvent([UInt8], Int, [UInt8])
    ///
    /// - parameter address - the tag memory address
    /// - parameter blocks - the number of memory 2-bytes blocks to read (1-50)
    public override func read(address: Int, blocks: Int) {
        var memoryToRead = [UInt8](repeating: 0, count: 3)
        var timeOutData = [UInt8](repeating: 0, count: 1)
        var command: String
        
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.readEvent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_WRONG_STATUS_ERROR, data: nil)
            return
        }
        
        if (address < 0 || address > 255) {
            passiveReader.responseListenerDelegate?.readEvent(tagID: getExtendedID(), error: AbstractResponseListener
                .READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR, data: nil)
            return
        }
        
        if (blocks < 0 || blocks > 50) {
            passiveReader.responseListenerDelegate?.readEvent(tagID: getExtendedID(), error: AbstractResponseListener
                .READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR, data: nil)
            return
        }
        
        memoryToRead[0] = UInt8(EPC_tag.USER_MEMORY_BANK)
        memoryToRead[1] = UInt8(address)
        memoryToRead[2] = UInt8(blocks)
        timeOutData[0] = UInt8(timeout / 100)
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.READ_COMMAND
        passiveReader.tagID = getID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_READ_COMMAND, parameters: timeOutData)
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: memoryToRead)
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }
    
    /// Start a tag memory TID read operation.
    ///
    /// The result of the read operation is notified invoking response listener method
    /// AbstractResponseListener.readEvent([UInt8], Int, [UInt8])
    ///
    /// - parameter length - TID length (bytes)
    /// - parameter password - tag read password (may be null or empty)
    public override func readTID(length: Int, password: [UInt8]?) {
        var memoryToRead = [UInt8](repeating: 0, count: 3)
        var timeOutData = [UInt8](repeating: 0, count: 1)
        var command: String
        
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.readTIDevent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_WRONG_STATUS_ERROR, TID: nil)
            return
        }
        
        if (length % 2 != 0 || length > 100) {
            passiveReader.responseListenerDelegate?.readTIDevent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR, TID: nil)
            return
        }
        
        memoryToRead[0] = UInt8(EPC_tag.TID_MEMORY_BANK)
        memoryToRead[1] = UInt8(0x00)
        memoryToRead[2] = UInt8(length / 2)
        timeOutData[0] = UInt8(timeout / 100)
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.READ_TID_COMMAND
        passiveReader.tagID = getExtendedID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_READ_COMMAND, parameters: timeOutData)
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: memoryToRead)
        if (password != nil) {
            command = passiveReader.appendDataToCommand(command: command, data: password!)
        }
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }
    
    public override func toString() -> String {
        var tmp = ""
        
        if (reverseID) {
            for n in stride(from: ID.count, to: 0, by: -1) {
                tmp = tmp + PassiveReader.byteToHex(val: Int(ID[n]))
            }
        } else {
            for n in 0..<ID.count {
                tmp = tmp + PassiveReader.byteToHex(val: Int(ID[n]))
            }
        }
        
        return tmp
    }
}
