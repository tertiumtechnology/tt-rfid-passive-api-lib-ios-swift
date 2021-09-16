/*
 * The MIT License
 *
 * Copyright 2017-2021 Tertium Technology.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import Foundation

public class EPC_tag: Tag {    
    /// EPC tag reserved memory bank.
    public static let RESERVED_MEMORY_BANK: Int = 0x00
    
    /// EPC tag kill password reserved memory address.
    public static let KILL_PASSWORD_ADDRESS: Int = 0x00
    
    /// EPC tag access password reserved memory address.
    public static let ACCESS_PASSWORD_ADDRESS: Int = 0x02
    
    /// EPC tag ID memory bank.
    public static let EPC_MEMORY_BANK: Int = 0x01
    
    /// EPC tag TID memory bank.
    public static let TID_MEMORY_BANK: Int = 0x02
    
    /// EPC tag user memory memory bank.
    public static let USER_MEMORY_BANK: Int = 0x03
    
    /// EPC tag ID writable and not lockable lock code.
    public static let ID_WRITABLE_NOTLOCKABLE: Int = 0x0C010F
    
    /// EPC tag TID writable and not lockable lock code.
    public static let TID_WRITABLE_NOTLOCKABLE: Int = 0x03004F
    
    /// EPC tag user memory writable and not lockable lock code.
    public static let MEMORY_WRITABLE_NOTLOCKABLE: Int = 0x00C01F
    
    /// EPC tag ID password writable lock code.
    public static let ID_PASSWORD_WRITABLE: Int = 0x0C020F
    
    /// EPC tag TID password writable lock code.
    public static let TID_PASSWORD_WRITABLE: Int = 0x03008F
    
    /// EPC tag user memory password writable lock code.
    public static let MEMORY_PASSWORD_WRITABLE: Int = 0x00C02F
    
    /// EPC tag ID unwritable lock code.
    public static let ID_NOTWRITABLE: Int = 0x0C0C0F
    
    /// EPC tag TID unwritable lock code.
    public static let TID_NOTWRITABLE: Int = 0x0300CF
    
    /// EPC tag user memory unwritable lock code.
    public static let MEMORY_NOTWRITABLE: Int = 0x00C03F
    
    /// EPC tag kill password readable/writable and not lockable lock code.
    public static let KILLPASSWORD_READABLE_WRITABLE_NOTLOCKABLE: Int = 0xC0100F
    
    /// EPC tag access password readable/writable and not lockable lock code.
    public static let ACCESSPASSWORD_READABLE_WRITABLE_NOTLOCKABLE: Int = 0x30040F
    
    /// EPC tag kill password password readable/writable lock code.
    public static let KILLPASSWORD_PASSWORD_READABLE_WRITABLE: Int = 0xC0200F
    
    /// EPC tag access password password readable/writable lock code.
    public static let ACCESSPASSWORD_PASSWORD_READABLE_WRITABLE: Int = 0x30080F
    
    /// EPC tag kill password unreadable/unwritable lock code.
    public static let KILLPASSWORD_UNREADABLE_UNWRITABLE: Int = 0xC0300F
 
    /// EPC tag access password unreadable/unwritable lock code.
    public static let ACCESSPASSWORD_UNREADABLE_UNWRITABLE: Int = 0x300C0F	
	
    private let PC: UInt16
    private let RSSI: Int16
	
	/// Class Constructor
	///
    /// - parameter PC - the tag PC (Protocol Code)
    /// - parameter ID - the tag ID
    /// - parameter passiveReader - reference to the passive reader object
    init(PC: UInt16, ID: [UInt8], passiveReader: PassiveReader) {
        self.PC = PC
        self.RSSI = -128;
        super.init(ID: ID, passiveReader: passiveReader)
    }
    
    /// Class Constructor
    ///
    /// - parameter RSSI - the tag RSSI at inventory time (dBm)
    /// - parameter PC - the tag PC (Protocol Code)
    /// - parameter ID - the tag ID
    /// - parameter passiveReader - reference to the passive reader object
    init(RSSI: Int16, PC: UInt16, ID: [UInt8], passiveReader: PassiveReader) {
        self.PC = PC
        self.RSSI = RSSI;
        super.init(ID: ID, passiveReader: passiveReader)
    }
    
    /// Get tag PC + ID.
	///
	/// - returns - the tag PC + ID as byte array
	public func getExtendedID() -> [UInt8] {
		var extendedID = [UInt8](repeating: 0, count: 2 + ID.count)
		let tmp = String(format:"%04X", PC)
		extendedID[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
		extendedID[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
		for n in 0..<ID.count {
			extendedID[n + 2] = ID[n]
		}
		
		return extendedID
	}

    /// Get tag PC (Protocol Control).
    ///
    /// - returns - the tag Protocol Control
    public func getPC() -> UInt16 {
        return PC
    }
    
    /// Get the tag RSSI at inventory time
    ///
    /// - returns - the tag RSSI value in dBm
    public func getRSSI() -> Int16 {
        return RSSI;
    }
    
    /// Start a tag memory TID read operation.
    ///
    /// The result of the read operation is notified invoking response listener method
    /// AbstractResponseListener.readEvent([UInt8], Int, [UInt8])
    ///
    /// - parameter length - TID length (bytes)
    /// - parameter password - tag read password (may be null or empty)
    public func readTID(length: Int, password: [UInt8]?) {
        var memoryToRead = [UInt8](repeating: 0, count: 3)
        var pcNumber = [UInt8](repeating: 0, count: 3)
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
        let tmp = String(format: "%04X", PC)
        pcNumber[0] = UInt8(timeout / 100)
        pcNumber[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        pcNumber[2] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.READ_TID_COMMAND
        passiveReader.tagID = getExtendedID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_READ_COMMAND, parameters: pcNumber)
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: memoryToRead)
        if (password != nil) {
            command = passiveReader.appendDataToCommand(command: command, data: password!)
        }
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }
    
    /// Start a tag memory ID write operation.
    ///
    /// The result of the write operation is notified invoking response listener methods
    /// AbstractResponseListener.writeIDevent([Uint8], Int)
    ///
    /// - parameter ID -  the new tag ID to write
    /// - parameter NSI - the tag Number System Identifier to write
    public func writeID(ID: [UInt8], NSI: UInt16) {
        var numberingSystemIdentifier = [UInt8](repeating: 0, count: 2)
        var command: String
        
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.writeIDevent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if (ID.count % 2 != 0 || ID.count < 12 || ID.count > 30) {
            passiveReader.responseListenerDelegate?.writeIDevent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        let tmp = String(format: "%04X", NSI)
        numberingSystemIdentifier[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        numberingSystemIdentifier[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.WRITEID_COMMAND
        passiveReader.tagID = getExtendedID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_WRITEID_COMMAND, parameters: [UInt8(timeout / 100)])
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: numberingSystemIdentifier)
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }
    
    /// Start a tag kill password operation.
    ///
    /// The result of the write operation is notified invoking response listener methods
    /// AbstractResponseListener.writePasswordEvent([UInt8], Int)
    ///
    /// - parameter kill_password - the new tag kill password (4 bytes)
    /// - parameter password - tag access password (may be null or empty)
    public func writeKillPassword(kill_password: [UInt8], password: [UInt8]?) {
        var memoryToWrite = [UInt8](repeating: 0, count: 3)
        var pcNumber = [UInt8](repeating: 0, count: 3)
        var command: String
        
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.writePasswordEvent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_WRONG_STATUS_ERROR);
            return
        }
        
        if (kill_password.count != 4) {
            passiveReader.responseListenerDelegate?.writePasswordEvent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR);
            return
        }
        
        memoryToWrite[0] = UInt8(EPC_tag.RESERVED_MEMORY_BANK)
        memoryToWrite[1] = UInt8(EPC_tag.KILL_PASSWORD_ADDRESS)
        memoryToWrite[2] = UInt8(2)
        let tmp = String(format: "%04X", PC)
        pcNumber[0] = UInt8(timeout / 100)
        pcNumber[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        pcNumber[2] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.WRITEKILLPASSWORD_COMMAND
        passiveReader.tagID = getExtendedID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_WRITE_COMMAND, parameters: pcNumber)
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: memoryToWrite)
        command = passiveReader.appendDataToCommand(command: command, data: kill_password)
        if (password != nil) {
            command = passiveReader.appendDataToCommand(command: command, data: password!)
        }
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }
    
    /// Start a tag access password operation.
    ///
    /// The result of the write operation is notified invoking response listener methods
    /// AbstractResponseListener.writePasswordEvent([UInt8], Int)
    ///
    /// - parameter accessPassword - the new tag access password (4 bytes)
    /// - parameter password - tag access password (may be null or empty)
    public func writeAccessPassword(accessPassword: [UInt8], password: [UInt8]?) {
        var memoryToWrite = [UInt8](repeating: 0, count: 3)
        var pcNumber = [UInt8](repeating: 0, count: 3)
        var command: String
        
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.writePasswordEvent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        if (accessPassword.count != 4) {
            passiveReader.responseListenerDelegate?.writePasswordEvent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        memoryToWrite[0] = UInt8(EPC_tag.RESERVED_MEMORY_BANK)
        memoryToWrite[1] = UInt8(EPC_tag.ACCESS_PASSWORD_ADDRESS)
        memoryToWrite[2] = UInt8(2)
        let tmp = String(format: "%04X", PC)
        pcNumber[0] = UInt8(timeout / 100)
        pcNumber[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        pcNumber[2] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.WRITEACCESSPASSWORD_COMMAND
        passiveReader.tagID = getExtendedID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_WRITE_COMMAND, parameters: pcNumber)
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: memoryToWrite)
        command = passiveReader.appendDataToCommand(command: command, data: accessPassword)
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
    /// - parameter password - tag access password (may be null or empty)
    public func read(address: Int, blocks: Int) {
        var memoryToRead = [UInt8](repeating: 0, count: 3)
        var pcNumber = [UInt8](repeating: 0, count: 3)
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
        let tmp = String(format: "%04X", PC)
        pcNumber[0] = UInt8(timeout / 100)
        pcNumber[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        pcNumber[2] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.READ_COMMAND
        passiveReader.tagID = getExtendedID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_READ_COMMAND, parameters: pcNumber)
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: memoryToRead)
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }
        
    /// Start a tag memory write operation.
    ///
    /// The result of the write operation is notified invoking response listener
    /// method AbstractResponseListener.writeEvent([UInt8], Int)
    ///
    /// - parameter address - the tag memory address
    /// - parameter data - the data bytes to write
    /// - parameter password - tag access password (may be null or empty)
    public func write(address: Int, data: [UInt8], password: [UInt8]?) {
        var memoryToWrite = [UInt8](repeating: 0, count: 3)
        var pcNumber = [UInt8](repeating: 0, count: 3)
        var blocks: UInt8
        var command: String
        
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.writeEvent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if (address < 0 || address > 255) {
            passiveReader.responseListenerDelegate?.writeEvent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        if (data.count % 2 != 0 || data.count > 100) {
            passiveReader.responseListenerDelegate?.writeEvent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        blocks = UInt8(data.count / 2)
        memoryToWrite[0] = UInt8(EPC_tag.USER_MEMORY_BANK)
        memoryToWrite[1] = UInt8(address)
        memoryToWrite[2] = UInt8(blocks)
        let tmp = String(format: "%04X", PC)
        pcNumber[0] = UInt8(timeout / 100)
        pcNumber[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        pcNumber[2] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.WRITE_COMMAND
        passiveReader.tagID = getExtendedID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_WRITE_COMMAND, parameters: pcNumber)
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: memoryToWrite)
        command = passiveReader.appendDataToCommand(command: command, data: data)
        if (password != nil) {
            command = passiveReader.appendDataToCommand(command: command, data: password!)
        }
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }

    /// Start a tag lock operation.
    ///
    /// The result of the lock operation is notified invoking response listener
    /// method AbstractResponseListener.lockEvent([UInt8], Int)
    ///
    /// - parameter lock_type -    the lock type
    /// - parameter password -     tag access password (may be null or empty)
    public func lock(lock_type: Int, password: [UInt8]?) {
        var payload = [UInt8](repeating: 0, count: 3)
        var pcNumber = [UInt8](repeating: 0, count: 3)
        var command: String
        
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.lockEvent(tagID: getExtendedID(), error: AbstractResponseListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        var tmp = String(format: "%04X", PC)
        pcNumber[0] = UInt8(timeout / 100)
        pcNumber[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        pcNumber[2] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        tmp = String(format: "%06X", lock_type)
        payload[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        payload[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        payload[2] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 4, end: 6)))
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.LOCK_COMMAND
        passiveReader.tagID = getExtendedID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_LOCK_COMMAND, parameters: pcNumber)
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: payload)
        if (password != nil) {
            command = passiveReader.appendDataToCommand(command: command, data: password!)
        }
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }

    /// Start a tag kill operation.
    ///
    /// The result of the kill operation is notified invoking response listener method 
	/// AbstractResponseListener.killEvent([UInt8], Int)
    ///
    /// - parameter password - tag kill password
    public func kill(password: [UInt8]) {
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
		
        let tmp = String(format: "%04X", PC)
		params[0] = UInt8(timeout / 100)
		params[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
		params[2] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.KILL_COMMAND
        passiveReader.tagID = getExtendedID()
        command = passiveReader.buildCommand(commandCode: PassiveReader.EPC_KILL_COMMAND, parameters: params)
        command = passiveReader.appendDataToCommand(command: command, data: ID)
        command = passiveReader.appendDataToCommand(command: command, data: password)
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
	}

    public override func toString() -> String {
        var tmp = String(format: "%04X", PC)
		
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
