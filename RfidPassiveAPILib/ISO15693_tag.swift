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

public class ISO15693_tag: Tag {
	/// Class Constructor
	///
    /// - parameter ID - the tag ID
    /// - parameter passiveReader - reference to the passive reader object
    override init(ID: [UInt8], passiveReader: PassiveReader) {
        super.init(ID: ID, passiveReader: passiveReader)
    }

    /// Start a tag memory read operation.
    /// 
    /// The result of the read operation is notified invoking response listener method
    /// AbstractResponseListener.readEvent([UInt8], int, [UInt8])
    /// 
    /// - parameter address - the tag memory address
    /// - parameter blocks - the number of memory 4-byte blocks to read (1-25)
    public func read(address: Int, blocks: Int) {
        var commandBytes = [UInt8](repeating: 0, count: 12)
		
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.readEvent(tagID: getID(), error: AbstractResponseListener.READER_DRIVER_WRONG_STATUS_ERROR, data: nil)
            return
        }
		
        if (address < 0 || address > 65535) {
            passiveReader.responseListenerDelegate?.readEvent(tagID: getID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR, data: nil)
            return
        }
		
        if (blocks < 0 || blocks > 25) {
            passiveReader.responseListenerDelegate?.readEvent(tagID: getID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR, data: nil)
            return
        }
		
        let tmp = String(format: "%04X", address)
		commandBytes[0] = UInt8(timeout / 100)
		commandBytes[1] = ID[0]
		commandBytes[2] = ID[1]
		commandBytes[3] = ID[2]
		commandBytes[4] = ID[3]
		commandBytes[5] = ID[4]
		commandBytes[6] = ID[5]
		commandBytes[7] = ID[6]
		commandBytes[8] = ID[7]
		commandBytes[9] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
		commandBytes[10] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
		commandBytes[11] = UInt8(blocks)
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.READ_COMMAND
        passiveReader.tagID = getID()
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: passiveReader.buildCommand(commandCode: PassiveReader.ISO15693_READ_COMMAND, parameters: commandBytes).data(using: String.Encoding.ascii)!)
    }
	
	/// Start a tag memory write operation.
    /// 
    /// The result of the read operation is notified invoking response listener method
    /// AbstractResponseListener.writeEvent([UInt8], int)
    /// 
    /// - parameter address - the tag memory address
    /// - parameter data - the data bytes to write
    public func write(address: Int, data: [UInt8]) {
        var commandBytes = [UInt8](repeating: 0, count: 12)
		
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.writeEvent(tagID: getID(), error: AbstractResponseListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
		
        if (address < 0 || address > 65535) {
            passiveReader.responseListenerDelegate?.writeEvent(tagID: getID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
		
        if (data.count % 4 != 0 || data.count > 100) {
            passiveReader.responseListenerDelegate?.writeEvent(tagID: getID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
		
        let tmp = String(format: "%04X", address)
		commandBytes[0] = UInt8(timeout / 100)
		commandBytes[1] = ID[0]
		commandBytes[2] = ID[1]
		commandBytes[3] = ID[2]
		commandBytes[4] = ID[3]
		commandBytes[5] = ID[4]
		commandBytes[6] = ID[5]
		commandBytes[7] = ID[6]
		commandBytes[8] = ID[7]
		commandBytes[9] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
		commandBytes[10] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
		commandBytes[11] = UInt8(data.count / 4)
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.WRITE_COMMAND
        passiveReader.tagID = getID()
        var command: String = passiveReader.buildCommand(commandCode: PassiveReader.ISO15693_WRITE_COMMAND, parameters: commandBytes);
        command = passiveReader.appendDataToCommand(command: command, data: data);
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }
    
    /// Start a tag lock operation.
    ///
    /// The result of the lock operation is notified invoking response listener method
    /// AbstractResponseListener.lockEvent([UInt8], Int)
    ///
    /// - parameter address - the tag memory address
    /// - parameter blocks - the number of memory 4-bytes blocks to lock (1-25)
    public func lock(address: Int, blocks: Int) {
        var commandBytes = [UInt8](repeating: 0, count: 12)
        
        if (passiveReader.status != PassiveReader.READY_STATUS) {
            passiveReader.responseListenerDelegate?.lockEvent(tagID: getID(), error: AbstractResponseListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if (address < 0 || address > 65535) {
            passiveReader.responseListenerDelegate?.lockEvent(tagID: getID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        if (blocks < 0 || blocks > 25) {
            passiveReader.responseListenerDelegate?.lockEvent(tagID: getID(), error: AbstractResponseListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        let tmp = String(format: "%04X", address)
        commandBytes[0] = UInt8(timeout / 100)
        commandBytes[1] = ID[0]
        commandBytes[2] = ID[1]
        commandBytes[3] = ID[2]
        commandBytes[4] = ID[3]
        commandBytes[5] = ID[4]
        commandBytes[6] = ID[5]
        commandBytes[7] = ID[6]
        commandBytes[8] = ID[7]
        commandBytes[9] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        commandBytes[10] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        commandBytes[11] = UInt8(blocks)
        passiveReader.status = PassiveReader.PENDING_COMMAND_STATUS
        passiveReader.pending = AbstractResponseListener.LOCK_COMMAND
        passiveReader.tagID = getID()
        passiveReader.deviceManager.sendData(device: passiveReader.connectedDevice!, data: passiveReader.buildCommand(commandCode: PassiveReader.ISO15693_LOCK_COMMAND, parameters: commandBytes).data(using: String.Encoding.ascii)!)
    }
    
    public override func toString() -> String {
        var tmp: String = ""
        
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
