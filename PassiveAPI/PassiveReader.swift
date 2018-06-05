/*
 * The MIT License
 *
 * Copyright 2017 Tertium Technology.
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
import TxRxLib

/// Represents the RFID/NFC tag reader
public class PassiveReader: TxRxDeviceDataProtocol {
	/// Passive reader internal state constants
	static internal let ERROR_STATUS: Int = -1
    static internal let NOT_INITIALIZED_STATUS: Int = 0
    static internal let UNINITIALIZED_STATUS: Int = 2
    static internal let READY_STATUS: Int = 3
    static internal let PENDING_COMMAND_STATUS: Int = 4
	
	/// Passive reader commands
    static internal let BEEPER_COMMAND: Int8 = 0x01
    static internal let LED_COMMAND: Int8 = 0x02
    static internal let STATUS_COMMAND: Int8 = 0x05
    static internal let MODE_COMMAND: Int8 = 0x06
    static internal let SETAUTOOFF_COMMAND: Int8 = 0x0D
    static internal let SETMODE_COMMAND: Int8 = 0x0E
    static internal let SETSTANDARD_COMMAND: Int8 = 0x0F
    static internal let EPC_INVENTORY_COMMAND: Int8 = 0x11
    static internal let EPC_WRITEID_COMMAND: Int8 = 0x12
    static internal let EPC_READ_COMMAND: Int8 = 0x13
    static internal let EPC_WRITE_COMMAND: Int8 = 0x14
    static internal let EPC_LOCK_COMMAND: Int8 = 0x15
    static internal let EPC_KILL_COMMAND: Int8 = 0x16
    static internal let EPC_SETREGISTER_COMMAND: Int8 = 0x1E
    static internal let EPC_SETPOWER_COMMAND: Int8 = 0x1F
    static internal let ISO15693_INVENTORY_COMMAND: Int8 = 0x21
    static internal let ISO15693_READ_COMMAND: Int8 = 0x23
    static internal let ISO15693_WRITE_COMMAND: Int8 = 0x24
    static internal let ISO15693_LOCK_COMMAND: Int8 = 0x25
    static internal let ISO15693_SETREGISTER_COMMAND: Int8 = 0x2E
    static internal let ISO15693_SETPOWER_COMMAND: Int8 = 0x2F
    static internal let ISO14443A_INVENTORY_COMMAND: Int8 = 0x31
    
    static private let REGISTER_RF_CHANNEL_SELECTION: UInt8 = 0xF0
    static private let REGISTER_BIT_RATE_SELECTION: UInt8 = 0xF1
    static private let REGISTER_PROTOCOL_EXTENSION_FLAG: UInt8 = 0xF3
    static private let REGISTER_OPTION_BITS: UInt8 = 0xF6
    static private let REGISTER_RF_PARAMETERS_FOR_TUNNEL_MODE: UInt8 = 0xFB
    static private let REGISTER_ADC_BATTERY_VALUE: UInt8 = 0xFC
     
	/// Passive reader retcodes
    static private let SUCCESSFUL_OPERATION_RETCODE: Int8 = 0x00
    static private let INVALID_MEMORY_RETCODE: Int8 = 0x01
    static private let LOCKED_MEMORY_RETCODE: Int8 = 0x02
    static private let INVENTORY_ERROR_RETCODE: Int8 = 0x03
    static private let INVALID_PARAMETER_RETCODE: Int8 = 0x0C
    static private let TIMEOUT_RETCODE: Int8 = 0x0D
    static private let UNIMPLEMENTED_COMMAND_RETCODE: Int8 = 0x0E
    static private let INVALID_COMMAND_RETCODE: Int8 = 0x0F
	
	/// PassiveReader singleton
    private static let _sharedInstance: PassiveReader = PassiveReader()
	
	/// TxRxManager instance
    internal let deviceManager: TxRxManager = TxRxManager.getInstance()
    
    /// TxRxDevice instance, the connected device
    internal var connectedDevice: TxRxDevice?
	
	/// Class delegates
	var readerListenerDelegate: AbstractReaderListenerProtocol? = nil
    var inventoryListenerDelegate: AbstractInventoryListenerProtocol? = nil
    var responseListenerDelegate: AbstractResponseListenerProtocol? = nil
	
	private var inventoryMode = 0, mode: Int = 0
    private var inventoryFeedback = 0, feedback: Int = 0
    private var inventoryFormat = 0, format: Int = 0
    private var inventoryMaxNumber = 0, maxNumber: Int = 0
    private var inventoryInterval = 0, interval: Int = 0
    private var inventoryTimeout = 0, timeout: Int = 0
    private var inventoryStandard = 0, standard: Int = 0
    private var HFdevice: Bool = false
    private var UHFdevice: Bool = false
    private var inventoryEnabled: Bool = false
	
	internal var tagID: [UInt8]?
	
	internal var status: Int
    internal var sequential: Int = 0
	internal var pending: Int = 0
    
    /// EPC standard.
    static let EPC_STANDARD:Int = 0x00
    
    /// ISO-15693 standard.
    static let ISO15693_STANDARD:Int = 0x01
    
    /// ISO-15443A standard.
    static let ISO14443A_STANDARD:Int = 0x02
    
    /// ISO-15693 and ISO14443A standards.
    static let ISO15693_AND_ISO14443A_STANDARD:Int = 0x03
    
    /// Inventory scan started by doInventory() method invocation.
    static let NORMAL_MODE:Int = 0x00
    
    /// Inventory scan started periodically (period set by PassiveReader.setInventoryParameters(Int, Int, Int))
    /// method invocation.
    static let SCAN_ON_TIME_MODE:Int = 0x01
    
    /// Inventory scan started by the reader device button pression.
    static let SCAN_ON_INPUT_MODE:Int = 0x02
    
    /// Sound and LED light feedback for inventory successful operation.
    static let FEEDBACK_SOUND_AND_LIGHT:Int = 0x00
    
    /// No local feedback for inventory successful operation.
    static let NO_FEEDBACK:Int = 0x01
    
    /// Inventory operation get ISO15693 and/or ISO14443A ID only.
    static private let ID_ONLY_FORMAT:Int = 0x01
    
    /// Inventory operation get EPC tag ID only.
    static private let EPC_ONLY_FORMAT:Int = 0x01
    
    /// Inventory operation get ECP tag ID and PC (Protocol Code).
    static private let EPC_AND_PC_FORMAT:Int = 0x03
    
    /// Inventory operation get EPC tag ID e TID (tag unique ID).
    static private let EPC_AND_TID_FORMAT:Int = 0x05
    
    /// Inventory operation get EPC tag ID, PC (Protocol Code) and TID (tag
    /// unique ID).
    static private let ECP_AND_PC_AND_TID_FORMAT:Int = 0x07
    
    /// Low battery status
    static let LOW_BATTERY_STATUS:Int = 0x00
    
    /// Charged battery status
    static let CHARGED_BATTERY_STATUS:Int = 0x01
    
    /// Charging battery status
    static let CHARGING_BATTERY_STATUS:Int = 0x02
    
    /// HF reader device half RF power
    static let HF_RF_HALF_POWER:Int = 0x00
    
    /// HF reader device full RF power
    static let HF_RF_FULL_POWER:Int = 0x01
    
    /// HF reader device automatic RF power management
    static let HF_RF_AUTOMATIC_POWER:Int = 0x00
    
    /// HF reader device fixed RF power
    static let HF_RF_FIXED_POWER:Int = 0x01
    
    /// UHF reader device 0dB RF power
    static let UHF_RF_POWER_0_DB:Int = 0x00
    
    /// UHF reader device -1dB RF power
    static let UHF_RF_POWER_MINUS_1_DB:Int = 0x01
    
    /// UHF reader device -2dB RF power
    static let UHF_RF_POWER_MINUS_2_DB:Int = 0x02
    
    /// UHF reader device -3dB RF power
    static let UHF_RF_POWER_MINUS_3_DB:Int = 0x03
    
    /// UHF reader device -4dB RF power
    static let UHF_RF_POWER_MINUS_4_DB:Int = 0x04
    
    /// UHF reader device -5dB RF power
    static let UHF_RF_POWER_MINUS_5_DB:Int = 0x05
    
    /// UHF reader device -6dB RF power
    static let UHF_RF_POWER_MINUS_6_DB:Int = 0x06
    
    /// UHF reader device -7dB RF power
    static let UHF_RF_POWER_MINUS_7_DB:Int = 0x07
    
    /// UHF reader device -8dB RF power
    static let UHF_RF_POWER_MINUS_8_DB:Int = 0x08
    
    /// UHF reader device -9dB RF power
    static let UHF_RF_POWER_MINUS_9_DB:Int = 0x09
    
    /// UHF reader device -10dB RF power
    static let UHF_RF_POWER_MINUS_10_DB:Int = 0x0A
    
    /// UHF reader device -11dB RF power
    static let UHF_RF_POWER_MINUS_11_DB:Int = 0x0B
    
    /// UHF reader device -12dB RF power
    static let UHF_RF_POWER_MINUS_12_DB:Int = 0x0C
    
    /// UHF reader device -13dB RF power
    static let UHF_RF_POWER_MINUS_13_DB:Int = 0x0D
    
    /// UHF reader device -14dB RF power
    static let UHF_RF_POWER_MINUS_14_DB:Int = 0x0E
    
    /// UHF reader device -15dB RF power
    static let UHF_RF_POWER_MINUS_15_DB:Int = 0x0F
    
    /// UHF reader device -16dB RF power
    static let UHF_RF_POWER_MINUS_16_DB:Int = 0x10
    
    /// UHF reader device -17dB RF power
    static let UHF_RF_POWER_MINUS_17_DB:Int = 0x011
    
    /// UHF reader device -18dB RF power
    static let UHF_RF_POWER_MINUS_18_DB:Int = 0x012
    
    /// UHF reader device -19dB RF power
    static let UHF_RF_POWER_MINUS_19_DB:Int = 0x013
    
    /// UHF reader device automatic RF power management
    static let UHF_RF_POWER_AUTOMATIC_MODE:Int = 0x00
    
    /// UHF reader device fixed RF power with low bias
    static let UHF_RF_POWER_FIXED_LOW_BIAS_MODE:Int = 0x01
    
    /// UHF reader device fixed RF power with high bias
    static let UHF_RF_POWER_FIXED_HIGH_BIAS_MODE:Int = 0x02
    
    /// ISO15693 tag with no option bits
    static let ISO15693_OPTION_BITS_NONE:Int = 0x00
    
    /// ISO15693 tag with option bit for lock operations
    static let ISO15693_OPTION_BITS_LOCK:Int = 0x01
    
    /// ISO15693 tag with option bit for write operations
    static let ISO15693_OPTION_BITS_WRITE:Int = 0x02
    
    /// ISO15693 tag with option bit for read operations
    static let ISO15693_OPTION_BITS_READ:Int = 0x04
    
    /// ISO15693 tag with option bit for inventory operations
    static let ISO15693_OPTION_BITS_INVENTORY:Int = 0x08
    
    /// ISO15693 low bit-rate tag operations
    static let ISO15693_LOW_BITRATE:Int = 0
    
    /// ISO15693 high bit-rate tag operations
    static let ISO15693_HIGH_BITRATE:Int = 1
    
    /// UHF reader device RF carrier frequency from 902.75MHz to 927.5MHz
    /// (50 radio channels with frequency hopping)
    static let RF_CARRIER_FROM_902_75_TO_927_5_MHZ:Int = 0x00
    
    /// UHF reader device RF carrier frequency from 915.25MHz to 927.5MHz
    /// (25 radio channels with frequency hopping)
    static let RF_CARRIER_FROM_915_25_TO_927_5_MHZ:Int = 0x01
    
    /// UHF reader device RF carrier frequency 865.7MHz (no frequency hopping)
    static let RF_CARRIER_865_7_MHZ:Int = 0x02
    
    /// UHF reader device RF carrier frequency 866.3MHz (no frequency hopping)
    static let RF_CARRIER_866_3_MHZ:Int = 0x03
    
    /// UHF reader device RF carrier frequency 866.9MHz (no frequency hopping)
    static let RF_CARRIER_866_9_MHZ:Int = 0x04
    
    /// UHF reader device RF carrier frequency 867.5MHz (no frequency hopping)
    static let RF_CARRIER_867_5_MHZ:Int = 0x05
    
    /// UHF reader device RF carrier frequency from 865.7MHz to 867.5MHz
    /// (4 radio channels with frequency hopping)
    static let RF_CARRIER_FROM_865_7_TO_867_5_MHZ:Int = 0x06
    
    /// UHF reader device RF carrier frequency 915.1MHz (no frequency hopping)
    static let RF_CARRIER_915_1_MHZ:Int = 0x07
    
    /// UHF reader device RF carrier frequency 915.7MHz (no frequency hopping)
    static let RF_CARRIER_915_7_MHZ:Int = 0x08
    
    /// UHF reader device RF carrier frequency 916.3MHz (no frequency hopping)
    static let RF_CARRIER_916_3_MHZ:Int = 0x09
    
    /// UHF reader device RF carrier frequency 916.9MHz (no frequency hopping)
    static let RF_CARRIER_916_9_MHZ:Int = 0x0A
    
    /// UHF reader device RF carrier frequency from 915.1MHz to 916.9MHz
    /// (4 radio channels with frequency hopping)
    static let RF_CARRIER_FROM_915_1_TO_916_9_MHZ:Int = 0x0B
    
    /// UHF reader device RF carrier frequency 902.75MHz (no frequency hopping)
    static let RF_CARRIER_902_75_MHZ:Int = 0x0C
    
    /// UHF reader device RF carrier frequency 908.75MHz (no frequency hopping)
    static let RF_CARRIER_908_75_MHZ:Int = 0x0D
    
    /// UHF reader device RF carrier frequency 915.25MHz (no frequency hopping)
    static let RF_CARRIER_915_25_MHZ:Int = 0x0E
    
    /// UHF reader device RF carrier frequency 921.25MHz (no frequency hopping)
    static let RF_CARRIER_921_25_MHZ:Int = 0x0F
    
    /// UHF reader device RF carrier frequency 925.25MHz (no frequency hopping)
    static let RF_CARRIER_925_25_MHZ:Int = 0x10
	
    static func getInstance() -> PassiveReader {
        return PassiveReader._sharedInstance
    }
    
	init() {
        status = PassiveReader.NOT_INITIALIZED_STATUS
        //deviceManager._delegate = self
        sequential = 0
        inventoryEnabled = false
        inventoryMode = PassiveReader.NORMAL_MODE
    }
    
    static func bytesToString(bytes: [UInt8]?) -> String {
        var str: String = ""
        
        if let bytes = bytes {
            for byte in bytes {
                str.append(byteToHex(val: Int(byte)))
            }
        } else {
            return "<nil>"
        }
        
        return str
    }
    
	static func byteToHex(val: Int) -> String {
		return String(format:"%02X", val & 0xFF)
	}
	
	static func hexToByte(hex: String) -> Int {
		return Int(strtoul(hex, nil, 16))
	}
	
	static func hexToWord(hex: String) -> Int {
		return Int(strtoul(hex, nil, 16))
	}
	
	/// Start a tag encrypted tunnel operation.
	/// 
	/// In encrypted tunnel operation the command bytes are directly sent to the
	/// reader device.
	/// 
	/// * The result of the tunnel operation is notified invoking reader listener
	/// methods
	///
	/// - parameter flag - flag byte (not encrypted)
	/// - parameter - command - the command to send to the tag
	public func ISO15693encryptedTunnel(flag: UInt8, command: [UInt8]) {
        if status != PassiveReader.READY_STATUS {
            if let readerListenerDelegate = readerListenerDelegate {
                readerListenerDelegate.resultEvent(command: AbstractReaderListener.ISO15693_ENCRYPTEDTUNNEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            }
            
            return
        }
        
        var frame = [UInt8](repeating: 0, count: 1+command.count)
        frame[0] = flag
        for n in 0..<command.count {
            frame[n+1] = command[n]
        }
        
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.ISO15693_ENCRYPTEDTUNNEL_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildTunnelCommand(parameters: frame).data(using: String.Encoding.ascii)!)
    }
    
    /// Start an ISO15693 reader tunnel operation.
    ///
    /// In tunnel operation the command bytes are directly sent to the reader device.
    ///
    /// The result of the tunnel operation is notified invoking reader listener
    /// methods
    /// - parameter command - the command to send to the tag
    public func ISO15693tunnel(command: [UInt8]) {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.ISO15693_TUNNEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.ISO15693_TUNNEL_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildTunnelCommand(parameters: command).data(using: String.Encoding.ascii)!)
    }
    
	/// Closes the reader driver
    internal func close() {
        // TODO: device manager close ?
        disconnect()
        deviceManager.disconnectDevice(device: connectedDevice!)
        status = PassiveReader.NOT_INITIALIZED_STATUS
    }
    
    public func getConnectedDevice() -> TxRxDevice? {
        return connectedDevice
    }
    
	/// Connects the reader device
	///
	/// - parameter readerAddress - The device name
    public func connect(readerAddress: String) {
        // TODO: implement caching system and keep UUIDs
        var device: TxRxDevice?
        
        disconnect()
        device = deviceManager.deviceFromDeviceName(name: readerAddress)
		if device == nil {
			readerListenerDelegate?.connectionFailureEvent(error: AbstractReaderListener.READER_CONNECT_DEVICE_NOT_FOUND_ERROR)
			return
		}
		
        device!.delegate = self
        deviceManager.connectDevice(device: device!)
    }
    
	/// Disconnects from the Ble device
    public func disconnect() {
        if let device = connectedDevice {
            if device.isConnected {
                deviceManager.disconnectDevice(device: connectedDevice!)
                status = PassiveReader.NOT_INITIALIZED_STATUS
            }
        }
    }
    
    /// Start an inventory operation.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) 
    /// and AbstractInventoryListener.inventoryEvent(Tag) methods invocation.
    public func doInventory() {
        if status != PassiveReader.READY_STATUS || !inventoryEnabled {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.INVENTORY_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        let parameter = [UInt8(inventoryTimeout)]
        if isHF() {
            deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_INVENTORY_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
        } else {
            // isUHF
            deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.EPC_INVENTORY_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
        }
    }
    
    /// Get the reader device battery level fro HF reader device.
    ///
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) and
    /// AbstractReaderListener.batteryLevelEvent(float)
    /// methods invocation.
    public func getBatteryLevel() {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_BATTERY_LEVEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if isUHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_BATTERY_LEVEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        
        let parameter = [UInt8(PassiveReader.REGISTER_ADC_BATTERY_VALUE)]
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_BATTERY_LEVEL_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_SETREGISTER_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
    }
	
    /// Get the reader device battery status.
    ///
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int)
    /// and AbstractReaderListener.batteryStatusEvent(Int) methods invocation.
	public func getBatteryStatus() {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_BATTERY_STATUS_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        let parameter = [UInt8(inventoryMode)]
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_BATTERY_STATUS_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.MODE_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
    }
    
    /// Get the UHF reader device RF frequency for EPC tags.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) and
    /// AbstractReaderListener.EPCfrequencyEvent(Int) invocation.
    public func getEPCfrequency() {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_EPC_FREQUENCY_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if isHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_EPC_FREQUENCY_COMMAND, error: AbstractReaderListener.UNKNOWN_COMMAND_ERROR)
            return
        }
        
        let parameter = [UInt8(PassiveReader.REGISTER_RF_CHANNEL_SELECTION)]
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_EPC_FREQUENCY_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.EPC_SETREGISTER_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
    }
    
    /// Get the reader device firmware version.
    ///
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) and
    /// AbstractReaderListener.firmwareVersionEvent(Int, Int) methods invocation.
    public func getFirmwareVersion() {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_FIRMWARE_VERSION_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        let parameter = [UInt8(inventoryStandard)]
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_FIRMWARE_VERSION_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.SETSTANDARD_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
    }
    
    /// Get the HF reader device bit-rate for ISO15693 tags.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) and
    /// AbstractReaderListener.ISO15693bitrateEvent(Int, boolean) methods invocation.
    public func getISO15693bitrate() {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_ISO15693_BITRATE_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if isUHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_ISO15693_BITRATE_COMMAND, error: AbstractReaderListener.UNKNOWN_COMMAND_ERROR)
            return
        }
        
        let parameter = [UInt8(PassiveReader.REGISTER_BIT_RATE_SELECTION)]
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_ISO15693_BITRATE_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_SETREGISTER_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
    }
    
    /// Get the HF reader device extension flag for ISO15693 tags.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) and
    /// AbstractReaderListener.ISO15693extensionFlagEvent(boolean, boolean) methods invocation.
    public func getISO15693extensionFlag() {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_ISO15693_EXTENSION_FLAG_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if isUHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_ISO15693_EXTENSION_FLAG_COMMAND, error: AbstractReaderListener.UNKNOWN_COMMAND_ERROR)
            return
        }
        
        let parameter = [UInt8(PassiveReader.REGISTER_PROTOCOL_EXTENSION_FLAG)]
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_ISO15693_EXTENSION_FLAG_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_SETREGISTER_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
    }
    
    /// Get the HF reader device option bits for ISO15693 tags.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) and
    /// AbstractReaderListener.ISO15693optionBitsEvent(Int) methods invocation.
    public func getISO15693optionBits() {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_ISO15693_OPTION_BITS_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            
            return
        }
        
        if isUHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_ISO15693_OPTION_BITS_COMMAND, error: AbstractReaderListener.UNKNOWN_COMMAND_ERROR)
            
            return
        }

        let parameter = [UInt8(PassiveReader.REGISTER_OPTION_BITS)]
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_ISO15693_OPTION_BITS_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_SETREGISTER_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
    }
    
    /// Get the HF reader device RF parameters to use ISO15693 tunnel mode.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) and 
	/// AbstractReaderListener.RFforISO15693tunnelEvent(Int, Int) methods invocation.
    public func getRFforISO15693tunnel() {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_RF_FOR_ISO15693_TUNNEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            
            return
        }
        
        if isUHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_RF_FOR_ISO15693_TUNNEL_COMMAND, error: AbstractReaderListener.UNKNOWN_COMMAND_ERROR)
            
            return
        }
        
        let parameter = [UInt8(PassiveReader.REGISTER_RF_PARAMETERS_FOR_TUNNEL_MODE)]
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_RF_FOR_ISO15693_TUNNEL_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.EPC_SETREGISTER_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
    }
    
    /// Get the configured RF power for HF/UHF reader device.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) and
    /// AbstractReaderListener.RFpowerEvent(Int, Int) methods invocation.
    public func getRFpower() {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_RF_POWER_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            
            return
        }
        
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_RF_POWER_COMMAND
        if isHF() {
            deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_SETPOWER_COMMAND, parameters: nil).data(using: String.Encoding.ascii)!)
        } else {
            deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.EPC_SETPOWER_COMMAND, parameters: nil).data(using: String.Encoding.ascii)!)
        }
    }
    
    /// Get the configured reader device shutdown time.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) and 
    /// AbstractReaderListener.shutdownTimeEvent(Int) methods invocation.
    public func getShutdownTime() {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_SHUTDOWN_TIME_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }

        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_SHUTDOWN_TIME_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.SETAUTOOFF_COMMAND, parameters: nil).data(using: String.Encoding.ascii)!)
    }
    
    /// Test the BLE link with reader device.
    ///
    /// - returns true - if the reader device is linked by BLE
    public func isAvailable(deviceAddress: String) -> Bool {
        var name: String?
        
        name = deviceManager.getDeviceName(device: connectedDevice!)
        return name == deviceAddress
    }
    
    /// Test the reader device type.
    ///
    /// - returns true - if the reader is an HF device for ISO15693 and/or ISO14443 tags.     
    public func isHF() -> Bool {
        if status < PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.IS_HF_COMMAND, error: AbstractReaderListener.READER_DRIVER_NOT_READY_ERROR)
            return false
        }
        
        return HFdevice
    }
    
    /// Test the reader device type.
    ///
    /// - returns true - if the reader is an UHF device for EPC tags.
    public func isUHF() -> Bool {
        if status < PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.IS_UHF_COMMAND, error: AbstractReaderListener.READER_DRIVER_NOT_READY_ERROR)
            return false
        }
        
        return UHFdevice
    }
    
    /// Command the the reader device to activate the LED light.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) method invocation.
	///
    /// - parameter ledStatus - if true light on the LED
    /// - parameter ledBlinking - the time for LED light to blink (milliseconds: 10-2540, 0 means no blink)     
    public func light(ledStatus: Bool, ledBlinking: Int) {
        var led = [UInt8(0), UInt8(0)]
        
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.LIGHT_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if (ledBlinking != 0 && (ledBlinking < 10 || ledBlinking > 2540)) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.LIGHT_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        if (ledBlinking == 0) {
            led[0] = UInt8(ledStatus ? 0xFF : 0x00)
        } else {
            led[0] = UInt8(ledBlinking / 10)
        }
        
        led[1] = UInt8(0)
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.LIGHT_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: Int8(PassiveReader.LED_COMMAND), parameters: led).data(using: String.Encoding.ascii)!)
    }
    
    /// Set the UHF reader device RF frequency for EPC tags.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) method invocation.
	///
    /// - parameter frequency - the RF frequency     
    public func setEPCfrequency(frequency: Int) {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_EPC_FREQUENCY_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if isHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_EPC_FREQUENCY_COMMAND, error: AbstractReaderListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        
        if (frequency < PassiveReader.RF_CARRIER_FROM_902_75_TO_927_5_MHZ || frequency > PassiveReader.RF_CARRIER_925_25_MHZ) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_EPC_FREQUENCY_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_EPC_FREQUENCY_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.EPC_SETREGISTER_COMMAND, parameters: [UInt8(frequency)]).data(using: String.Encoding.ascii)!)
    }
    
    /// Set the HF reader device bit-rate for ISO15693 tags.
    ///
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) method invocation.
    ///
    /// - parameter bitrate - the bit rate
    /// - parameter permanent - if true the extension flag configuration is permanent     
    public func setISO15693bitrate(bitrate: Int, permanent: Bool) {
        var data = [UInt8(0), UInt8(0)]
        
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_ISO15693_BITRATE_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if isUHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_ISO15693_BITRATE_COMMAND, error: AbstractReaderListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return

        }
        
        if bitrate < PassiveReader.ISO15693_LOW_BITRATE || bitrate > PassiveReader.ISO15693_HIGH_BITRATE {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_ISO15693_BITRATE_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        if permanent {
            data[1] = (bitrate == PassiveReader.ISO15693_HIGH_BITRATE ? 0x01 : 0x00)
        } else {
            data[1] = (bitrate == PassiveReader.ISO15693_HIGH_BITRATE ? 0x03 : 0x02)
        }
        
        data[0] = UInt8(PassiveReader.REGISTER_BIT_RATE_SELECTION)
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_ISO15693_BITRATE_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_SETREGISTER_COMMAND, parameters: data).data(using: String.Encoding.ascii)!)
    }
    
    /// Set the HF reader device extension flag for ISO15693 tags.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) method invocation.
    ///
    /// - parameter flag - if true the extension flag is configured
    /// - parameter permanent - if true the extension flag configuration is permanent
    public func setISO15693extensionFlag(flag: Bool, permanent: Bool) {
        var data = [UInt8(0), UInt8(0)]
        
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_ISO15693_EXTENSION_FLAG_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if isUHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_ISO15693_EXTENSION_FLAG_COMMAND, error: AbstractReaderListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        
        if permanent {
            data[1] = (flag ? 0x01 : 0x00)
        } else {
            data[1] = (flag ? 0x03 : 0x02)
        }
        
        data[0] = UInt8(PassiveReader.REGISTER_PROTOCOL_EXTENSION_FLAG)
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_ISO15693_EXTENSION_FLAG_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_SETREGISTER_COMMAND, parameters: data).data(using: String.Encoding.ascii)!)
    }
    
    /// Set the HF reader device option bits for ISO15693 tags.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) method invocation.
    ///
    /// - parameter optionBits - the option bits     
    public func setISO15693optionBits(optionBits: Int) {
        var data = [UInt8(0), UInt8(0)]
        
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_ISO15693_OPTION_BITS_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if isUHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_ISO15693_OPTION_BITS_COMMAND, error: AbstractReaderListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
            
        }
        
        if optionBits < PassiveReader.ISO15693_OPTION_BITS_NONE || optionBits > PassiveReader.ISO15693_OPTION_BITS_LOCK {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_ISO15693_OPTION_BITS_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        data[0] = UInt8(PassiveReader.REGISTER_BIT_RATE_SELECTION)
        data[1] = UInt8(optionBits)
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_ISO15693_OPTION_BITS_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_SETREGISTER_COMMAND, parameters: data).data(using: String.Encoding.ascii)!)
    }
    
    /// Set the inventory operating mode for the reader device.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) method invocation.
    ///
    /// - parameter mode - the inventory operating mode     
    public func setInventoryMode(mode: Int) {
        var data = [UInt8(0)]
        
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_INVENTORY_MODE_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if mode < PassiveReader.NORMAL_MODE || mode > PassiveReader.SCAN_ON_INPUT_MODE {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_INVENTORY_MODE_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        self.mode = mode
        data[0] = UInt8(mode)
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_INVENTORY_MODE_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.MODE_COMMAND, parameters: data).data(using: String.Encoding.ascii)!)
    }
	
    /// Set the inventory parameters
    /// 
    /// The parameters are permanently configured.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) method invocation.
	///
    /// - parameter feedback - the reader device local feedback for detected tag(s)
    /// - parameter timeout  - the inventory scan time (milliseconds: 100-2000)
    /// - parameter interval - the inventory repetition period (milliseconds: 100-25500)   
    public func setInventoryParameters(feedback: Int, timeout: Int, interval: Int) {
        var data = [UInt8](repeating: 0, count: 6)

        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_INVENTORY_PARAMETERS_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if feedback < PassiveReader.FEEDBACK_SOUND_AND_LIGHT || feedback > PassiveReader.NO_FEEDBACK {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_INVENTORY_PARAMETERS_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        if timeout < 100 || timeout > 2000 {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_INVENTORY_PARAMETERS_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        if interval < 100 || interval > 25500 {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_INVENTORY_PARAMETERS_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        self.feedback = feedback
        if isHF() {
            format = PassiveReader.ID_ONLY_FORMAT
        } else {
            format = PassiveReader.EPC_AND_PC_FORMAT
        }
        
        maxNumber = 0
        self.timeout = timeout / 100
        self.interval = interval / 100
        
        data[0] = UInt8(mode)
        data[1] = UInt8(feedback)
        data[2] = UInt8(format)
        data[3] = UInt8(maxNumber)
        data[4] = UInt8(timeout / 100)
        data[5] = UInt8(interval / 100)
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_INVENTORY_PARAMETERS_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.SETMODE_COMMAND, parameters: data).data(using: String.Encoding.ascii)!)
    }
    
    /// Set the inventory standard type for the HF reader device.
    ///
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) method invocation.
    ///
    /// - parameter - standard the standard type     
	public func setInventoryType(standard: Int) {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_INVENTORY_TYPE_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if standard < PassiveReader.EPC_STANDARD || standard > PassiveReader.ISO15693_AND_ISO14443A_STANDARD {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_INVENTORY_TYPE_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        self.standard = standard
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_INVENTORY_TYPE_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.SETSTANDARD_COMMAND, parameters: [UInt8(standard)]).data(using: String.Encoding.ascii)!)
    }    
	
    /// Set the HF reader device RF parameters to use ISO15693 tunnel mode.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) method invocation.
    /// 
    /// - parameter delay - the delay from RF power switch-on and command transmission (milliseconds: 0-255)
    /// - parameter timeout - the time before RF power switch-off (seconds: 0-255)     
    public func setRFforISO15693tunnel(delay: Int, timeout: Int) {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_RF_FOR_ISO15693_TUNNEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if isUHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_RF_FOR_ISO15693_TUNNEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        
        if delay < 0 || delay > 255 {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_RF_FOR_ISO15693_TUNNEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        if timeout < 0 || timeout > 255 {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_RF_FOR_ISO15693_TUNNEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }

        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_RF_FOR_ISO15693_TUNNEL_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_SETREGISTER_COMMAND, parameters: [UInt8(timeout), UInt8(delay)]).data(using: String.Encoding.ascii)!)
    }
    
    /// Set the RF power for HF/UHF reader device.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) method invocation.
    ///
    /// - parameter level - the RF power level
    /// - parameter mode - the RF power mode     
    public func setRFpower(level: Int, mode: Int) {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_RF_POWER_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }

        if isHF() {
            if level < PassiveReader.HF_RF_HALF_POWER || level > PassiveReader.HF_RF_FULL_POWER {
                readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_RF_POWER_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
                return
            }

            if mode < PassiveReader.HF_RF_AUTOMATIC_POWER || level > PassiveReader.HF_RF_FIXED_POWER {
                readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_RF_POWER_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
                return
            }
        } else {
            if level < PassiveReader.UHF_RF_POWER_0_DB || level > PassiveReader.UHF_RF_POWER_MINUS_19_DB {
                readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_RF_POWER_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
                return
            }
            
            if mode < PassiveReader.UHF_RF_POWER_AUTOMATIC_MODE || level > PassiveReader.UHF_RF_POWER_FIXED_HIGH_BIAS_MODE {
                readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_RF_POWER_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
                return
            }
        }

        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_RF_POWER_COMMAND
        var cmdCode: Int8
        
        if isHF() {
            cmdCode = PassiveReader.ISO15693_SETPOWER_COMMAND
        } else {
            cmdCode = PassiveReader.EPC_SETPOWER_COMMAND
        }
        
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: cmdCode, parameters: [UInt8(level), UInt8(mode)]).data(using: String.Encoding.ascii)!)
    }
    
    /// Set the shutdown time of the reader device if inactive.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) method invocation.
    ///
    /// - parameter time - the inactive time before reader device switch off (seconds: 10-64800)
    public func setShutdownTime(time: Int) {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_SHUTDOWN_TIME_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if time < 10 || time > 64800 {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_SHUTDOWN_TIME_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        let tmp = String(format: "%04X", time)
        let sub1 = String(tmp.prefix(2))
        let sub2 = String(tmp.suffix(2))
        let shutdownTime = [UInt8(PassiveReader.hexToByte(hex: sub1)), UInt8(PassiveReader.hexToByte(hex: sub2))]
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_SHUTDOWN_TIME_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.SETAUTOOFF_COMMAND, parameters: shutdownTime).data(using: String.Encoding.ascii)!)
    }
    
    /// Command the the reader device to generate a sound.
    /// 
    /// Response to the command received via AbstractReaderListener.ResultEvent(Int, Int) method invocation.
    ///
    /// - parameter frequency - the sound starting frequency (Hertz: 40-20000)
    /// - parameter step - the frequency step for repeated sounds (Hertz: 40-10000)
    /// - parameter duration - the single sound duration (milliseconds: 10-2550)
    /// - parameter interval - the time interval for repeated sounds (milliseconds: 10-2550)
    /// - parameter repetition - the number of sound repetition (0-255)
    public func sound(frequency: Int, step: Int, duration: Int, interval: Int, repetition: Int) {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SOUND_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if frequency < 40 || frequency > 20000 {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SOUND_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }

        if step < 40 || step > 10000 {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SOUND_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }

        if duration < 10 || duration > 2550 {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SOUND_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }

        if interval < 10 || interval > 2550 {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SOUND_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }

        if repetition < 0 || repetition > 255 {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SOUND_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        var tmp = String(format: "%04X", frequency)
        let startFrequency = [UInt8(PassiveReader.hexToByte(hex: String(tmp.prefix(2)))), UInt8(PassiveReader.hexToByte(hex: String(tmp.suffix(2))))]
        if (step >= 0) {
            tmp = String(format: "%04X", step)
        } else {
            tmp = String(format: "%04X", -step)
        }
        
        let frequencyStep = [UInt8(PassiveReader.hexToByte(hex: String(tmp.prefix(2)))), UInt8(PassiveReader.hexToByte(hex: String(tmp.suffix(2))))]
        
        let data = startFrequency + [UInt8(duration/10)] + [UInt8(interval/10)] + [UInt8(repetition)] + frequencyStep + [UInt8((step >= 0 ? 0x00 : 0x01))]
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SOUND_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BEEPER_COMMAND, parameters: data).data(using: String.Encoding.ascii)!)
    }
    
    /// Test the reader device functionality.
    /// 
    /// Response to the command received via AbstractReaderListener.resultEvent(Int, Int) 
	/// and AbstractReaderListener.availabilityEvent(boolean) methods invocation.
    public func testAvailability() {
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.TEST_AVAILABILITY_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.TEST_AVAILABILITY_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.SETSTANDARD_COMMAND, parameters: nil).data(using: String.Encoding.ascii)!)
    }
    
	internal func appendDataToCommand(command: String, data: [UInt8]) -> String {
		var frameLength = command.count - 2
        let index = command.index(command.startIndex, offsetBy: 4)
		var tail: String = String(command[index...])
		
		for appendData in data {
            tail = tail + PassiveReader.byteToHex(val: Int(appendData))
		}
		
		frameLength = frameLength + data.count * 2
        let builtCommand = "$:" + PassiveReader.byteToHex(val: frameLength) + tail
		return builtCommand
	}
    
    internal func buildCommand(commandCode: Int8, parameters: [UInt8]?) -> String {
        var command: String = "$:"
        
        if parameters == nil {
            command = command + PassiveReader.byteToHex(val: 6)
            command = command + PassiveReader.byteToHex(val: sequential)
            sequential = sequential + 1
            command = command + PassiveReader.byteToHex(val: Int(commandCode))
        } else {
            command = command + PassiveReader.byteToHex(val: 6 + 2 * parameters!.count)
            command = command + PassiveReader.byteToHex(val: sequential)
            sequential = sequential + 1
            command = command + PassiveReader.byteToHex(val: Int(commandCode))
            for param in parameters! {
                command = command + PassiveReader.byteToHex(val: Int(param))
            }
        }
        
        return command.uppercased()
    }
    
	internal func buildTunnelCommand(parameters: [UInt8]) -> String {
		var command: String = "#:"
		
		for param in parameters {
            command = command + PassiveReader.byteToHex(val: Int(param))
		}
		
		return command.uppercased()
	}
    
    // TxRxDeviceDataProtocol implementation
	
    /// Informs delegate an error while connecting device happened
    ///
    /// - parameter device: The TxRxDevice on which the error occoured
    /// - parameter error: An NSError class instance describing the error
    public func deviceConnectError(device: TxRxDevice, error: NSError) {
        status = PassiveReader.ERROR_STATUS
		connectedDevice = nil
        switch error.code {
            case TxRxManagerErrors.ErrorCodes.ERROR_DEVICE_CONNECT_TIMED_OUT.rawValue:
                readerListenerDelegate?.connectionFailureEvent(error: AbstractReaderListener.READER_CONNECT_TIMEOUT_ERROR)
            
            default:
                readerListenerDelegate?.connectionFailureEvent(error: AbstractReaderListener.READER_CONNECT_GENERIC_ERROR)
        }
    }
    
    /// Informs delegate a device has been connected
    ///
    /// - parameter device: The connected TxRxDevice
    public func deviceConnected(device: TxRxDevice) {
        status = PassiveReader.UNINITIALIZED_STATUS
    }
    
    /// Informs a connected device is ready to operate and has been identified as a Tertium BLE device
    ///
    /// - parameter device: The TxRxDevice correctly identified
    public func deviceReady(device: TxRxDevice) {
        connectedDevice = device
        status = PassiveReader.UNINITIALIZED_STATUS
		
        //
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.SETSTANDARD_COMMAND, parameters: nil).data(using: String.Encoding.ascii)!)
    }
	
	func writeTimeoutError() {
		switch status {
			case PassiveReader.ERROR_STATUS,
				 PassiveReader.NOT_INITIALIZED_STATUS,
				 PassiveReader.UNINITIALIZED_STATUS:
					status = PassiveReader.ERROR_STATUS
					readerListenerDelegate?.connectionFailureEvent(error: AbstractResponseListener.READER_WRITE_TIMEOUT_ERROR)
				
			//case READY_STATUS:
				
			case PassiveReader.PENDING_COMMAND_STATUS:
				if (pending >= AbstractReaderListener.SOUND_COMMAND && pending <= AbstractReaderListener.ISO15693_ENCRYPTEDTUNNEL_COMMAND) {
					readerListenerDelegate?.resultEvent(command: pending, error: AbstractReaderListener.READER_WRITE_TIMEOUT_ERROR)
				} else {
					switch (pending) {
						case AbstractResponseListener.READ_COMMAND:
							responseListenerDelegate?.readEvent(tagID: tagID, error: AbstractResponseListener.READER_WRITE_TIMEOUT_ERROR, data: nil)
							
						case AbstractResponseListener.WRITE_COMMAND:
							responseListenerDelegate?.writeEvent(tagID: tagID, error: AbstractResponseListener.READER_WRITE_TIMEOUT_ERROR)
							
						case AbstractResponseListener.LOCK_COMMAND:
							responseListenerDelegate?.lockEvent(tagID: tagID, error: AbstractResponseListener.READER_WRITE_TIMEOUT_ERROR)
							
						case AbstractResponseListener.WRITEID_COMMAND:
							responseListenerDelegate?.writeIDevent(tagID: tagID, error: AbstractResponseListener.READER_WRITE_TIMEOUT_ERROR)
							
						case AbstractResponseListener.READ_TID_COMMAND:
							responseListenerDelegate?.readTIDevent(tagID: tagID, error: AbstractResponseListener.READER_WRITE_TIMEOUT_ERROR, TID: nil)
							
						case AbstractResponseListener.KILL_COMMAND:
							responseListenerDelegate?.killEvent(tagID: tagID, error: AbstractResponseListener.READER_WRITE_TIMEOUT_ERROR)
							
						case AbstractResponseListener.WRITEKILLPASSWORD_COMMAND,
							AbstractResponseListener.WRITEACCESSPASSWORD_COMMAND:
							responseListenerDelegate?.writePasswordEvent(tagID: tagID, error: AbstractResponseListener.READER_WRITE_TIMEOUT_ERROR)
                        
                        default:
                            break
					}
				}

				status = PassiveReader.READY_STATUS

            default:
                break
				
		}		
	}
    
    /// Informs delegate there has been an error sending data to device
    ///
    /// - parameter device: The TxRxDevice on which the error occoured
    /// - parameter error: An NSError class instance describing the error
    public func deviceWriteError(device: TxRxDevice, error: NSError) {
		let errorCode = AbstractReaderListener.READER_WRITE_FAIL_ERROR
		
		if error.code == TxRxManagerErrors.ErrorCodes.ERROR_DEVICE_SENDING_DATA_TIMEOUT.rawValue {
			writeTimeoutError()
			return
		}
		
		switch status {
			case PassiveReader.ERROR_STATUS,
				PassiveReader.NOT_INITIALIZED_STATUS,
				PassiveReader.UNINITIALIZED_STATUS:
					status = PassiveReader.ERROR_STATUS
					readerListenerDelegate?.connectionFailureEvent(error: errorCode)
				
			//case READY_STATUS:
			
			case PassiveReader.PENDING_COMMAND_STATUS:
				if (pending >= AbstractReaderListener.SOUND_COMMAND && pending <= AbstractReaderListener.ISO15693_ENCRYPTEDTUNNEL_COMMAND) {
					readerListenerDelegate?.resultEvent(command: pending, error: errorCode)
				} else {
					switch pending {
						case AbstractResponseListener.READ_COMMAND:
                            responseListenerDelegate?.readEvent(tagID: tagID, error: errorCode, data: nil)
							
						case AbstractResponseListener.WRITE_COMMAND:
							responseListenerDelegate?.writeEvent(tagID: tagID, error: errorCode)
							
						case AbstractResponseListener.LOCK_COMMAND:
							responseListenerDelegate?.lockEvent(tagID: tagID, error: errorCode)
							
						case AbstractResponseListener.WRITEID_COMMAND:
							responseListenerDelegate?.writeIDevent(tagID: tagID, error: errorCode)
							
						case AbstractResponseListener.READ_TID_COMMAND:
							responseListenerDelegate?.readTIDevent(tagID: tagID, error: errorCode, TID: nil)
							
						case AbstractResponseListener.KILL_COMMAND:
							responseListenerDelegate?.killEvent(tagID: tagID, error: errorCode)
							
						case AbstractResponseListener.WRITEKILLPASSWORD_COMMAND,
							AbstractResponseListener.WRITEACCESSPASSWORD_COMMAND:
							responseListenerDelegate?.writePasswordEvent(tagID: tagID, error: errorCode)
                        
                        default:
                            break
					}
				}
				
				status = PassiveReader.READY_STATUS
            
            default:
                break
		}
    }
    
    /// Informs delegate the last sendData operation has succeeded
    ///
    /// - parameter device: The TxRxDevice which successfully received the data
    public func sentData(device: TxRxDevice) {
    }
	
	public func readNotifyTimeout() {
		switch status {
			case PassiveReader.ERROR_STATUS,
				 PassiveReader.NOT_INITIALIZED_STATUS,
				 PassiveReader.UNINITIALIZED_STATUS:
                    status = PassiveReader.ERROR_STATUS
					readerListenerDelegate?.connectionFailureEvent(error: AbstractResponseListener.READER_READ_TIMEOUT_ERROR)
			
			// case READY_STATUS:			
			case PassiveReader.PENDING_COMMAND_STATUS:
				if (pending >= AbstractReaderListener.SOUND_COMMAND && pending <= AbstractReaderListener.ISO15693_ENCRYPTEDTUNNEL_COMMAND) {
					readerListenerDelegate?.resultEvent(command: pending, error: AbstractReaderListener.READER_READ_TIMEOUT_ERROR)
				} else {
					switch pending {
						case AbstractResponseListener.READ_COMMAND:
							responseListenerDelegate?.readEvent(tagID: tagID, error: AbstractResponseListener.READER_READ_TIMEOUT_ERROR, data: nil)

						case AbstractResponseListener.WRITE_COMMAND:
							responseListenerDelegate?.writeEvent(tagID: tagID, error: AbstractResponseListener.READER_READ_TIMEOUT_ERROR)
						
						case AbstractResponseListener.LOCK_COMMAND:
							responseListenerDelegate?.lockEvent(tagID: tagID, error: AbstractResponseListener.READER_READ_TIMEOUT_ERROR)
							
						case AbstractResponseListener.WRITEID_COMMAND:
							responseListenerDelegate?.writeIDevent(tagID: tagID, error: AbstractResponseListener.READER_READ_TIMEOUT_ERROR)
							
						case AbstractResponseListener.READ_TID_COMMAND:
							responseListenerDelegate?.readTIDevent(tagID: tagID, error: AbstractResponseListener.READER_READ_TIMEOUT_ERROR, TID: nil)
							
						case AbstractResponseListener.KILL_COMMAND:
							responseListenerDelegate?.killEvent(tagID: tagID, error: AbstractResponseListener.READER_READ_TIMEOUT_ERROR)
							
						case AbstractResponseListener.WRITEKILLPASSWORD_COMMAND,
							 AbstractResponseListener.WRITEACCESSPASSWORD_COMMAND:
							responseListenerDelegate?.writePasswordEvent(tagID: tagID, error: AbstractResponseListener.READER_WRITE_TIMEOUT_ERROR)
                        
                        default:
                            break
					}
				}
				
				status = PassiveReader.READY_STATUS
			
			default:
				break
		}
	}
    
    /// Informs delegate there has been an error receiving data from device
    ///
    /// - parameter device: The TxRxDevice on which the error occoured
    /// - parameter error: An NSError class instance describing the error
    public func deviceReadError(device: TxRxDevice, error: NSError) {
        let errorCode: Int = AbstractReaderListener.READER_READ_FAIL_ERROR
		
		if error.code == TxRxManagerErrors.ErrorCodes.ERROR_DEVICE_RECEIVING_DATA_TIMEOUT.rawValue {
			readNotifyTimeout()
			return
		}
		
		switch status {
			case PassiveReader.ERROR_STATUS,
				 PassiveReader.NOT_INITIALIZED_STATUS,
				 PassiveReader.UNINITIALIZED_STATUS:
					status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailureEvent(error: errorCode)
					
			//case READY_STATUS

            case PassiveReader.PENDING_COMMAND_STATUS:
				if pending >= AbstractReaderListener.SOUND_COMMAND && pending <= AbstractReaderListener.ISO15693_ENCRYPTEDTUNNEL_COMMAND {
					readerListenerDelegate?.resultEvent(command: pending, error: errorCode)
				} else {
					switch(pending) {
						case AbstractResponseListener.READ_COMMAND:
                            responseListenerDelegate?.readEvent(tagID: tagID, error: errorCode, data: nil)
							
						case AbstractResponseListener.WRITE_COMMAND:
							responseListenerDelegate?.writeEvent(tagID: tagID, error: errorCode)
							
						case AbstractResponseListener.LOCK_COMMAND:
							responseListenerDelegate?.lockEvent(tagID: tagID, error: errorCode)
							
						case AbstractResponseListener.WRITEID_COMMAND:
							responseListenerDelegate?.writeIDevent(tagID: tagID, error: errorCode)

						case AbstractResponseListener.READ_TID_COMMAND:
							responseListenerDelegate?.readTIDevent(tagID: tagID, error: errorCode, TID: nil)

						case AbstractResponseListener.KILL_COMMAND:
							responseListenerDelegate?.killEvent(tagID: tagID, error: errorCode)

						case AbstractResponseListener.WRITEKILLPASSWORD_COMMAND,
							 AbstractResponseListener.WRITEACCESSPASSWORD_COMMAND:
                            responseListenerDelegate?.writePasswordEvent(tagID: tagID, error: errorCode)

						default:
							break
					}
				}
				
				status = PassiveReader.READY_STATUS
            
            default:
                break
		}		
    }
    
    class ReaderAnswer {
        private var data = [UInt8](repeating: 0, count: 0)
        private var responseString: String = ""
        private var length: Int = 0
        private var returnCode: Int = 0xFF
        private var sequential: Int = 0
        private var valid: Bool = false
        
        init(answer: String) {
            length = PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: answer, start: 2, end: 4))
            if length >= 6 {
                if length == answer.count - 2 {
                    // $:0800000
                    sequential = PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: answer, start: 4, end: 6))
                    returnCode = PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: answer, start: 6, end: 8))
                    data = [UInt8](repeating: 0, count: (length - 5) / 2)
                    responseString = answer
                    for n in 0..<data.count {
                        data[n] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: answer, start: 8 + 2 * n, end: 8 + 2 * n + 2)))
                    }
                    valid = true
                }
            }
        }
        
        func getData() -> [UInt8] {
            return data
        }
        
        func getSequential() -> Int {
            return sequential
        }
        
        func getReturnCode() -> Int {
            return returnCode
        }
        
        func getLength() -> Int {
            return length
        }
    }
    
    /// Informs delegate a Tertium BLE device has sent data
    ///
    /// NOTE: This can even happen PASSIVELY without issuing a command
    ///
    /// - parameter device: The TxRxDevice which sent the data
    /// - parameter data: the data received from the device (usually ASCII bytes)
    public func receivedData(device: TxRxDevice, data: Data) {
        var dataString: String?
        var tunnelAnswer: [UInt8]? = nil
        var responseType: String?
        var answer: ReaderAnswer? = nil
        var tag: Tag?

        if (data.count == 0) {
            status = PassiveReader.READY_STATUS
            return
        }
        
        dataString = String(data: data, encoding: .ascii)
        let splitted = dataString?.components(separatedBy: "\r\n")
        if let splitted = splitted {
            for chunk in splitted {
                if chunk.count == 0 {
                    continue
                }
                
                responseType = PassiveReader.getStringCharAt(str: chunk, at: 0)
                if responseType == "$" {
                    // Command answer
                    answer = ReaderAnswer(answer: chunk)
                } else if responseType == "#" {
                    // Tunnel command answer
                    tunnelAnswer = [UInt8](repeating: 0, count: ((data.count - 2) / 2))
                    for n in 0..<tunnelAnswer!.count {
                        tunnelAnswer![n] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: chunk, start: 2 + 2 * n, end: 2 + 2 * n + 2)))
                    }
                } else {
                    // Tag answer
                    if HFdevice {
                        var ID = [UInt8](repeating: 0, count: chunk.count / 2)
                        for n in 0..<ID.count {
                            ID[n] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: chunk, start: 2 * n, end: 2 * n + 2)))
                        }
                        if ID.count == 8 {
                            tag = ISO15693_tag(ID: ID, passiveReader: self)
                        } else {
                            tag = ISO14443A_tag(ID: ID, passiveReader: self)
                        }
                        inventoryListenerDelegate?.inventoryEvent(tag: tag!)
                    } else if UHFdevice {
                        if chunk.count > 4 {
                            var PC: UInt16
                            
                            PC = UInt16(PassiveReader.hexToWord(hex: PassiveReader.getStringSubString(str: chunk, start: 0, end: 4)))
                            var ID = [UInt8](repeating: 0, count: (chunk.count - 4) / 2)
                            for n in 0..<ID.count {
                                ID[n] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: chunk, start: 4 + 2 * n, end: 4 + 2 * n + 2)))
                            }
                            tag = EPC_tag(PC: PC, ID: ID, passiveReader: self)
                            inventoryListenerDelegate?.inventoryEvent(tag: tag!)
                        }
                    }
                }
            }
        }
        
        if answer == nil && tunnelAnswer == nil {
            return
        }
        
        switch (status) {
            case PassiveReader.ERROR_STATUS,
                 PassiveReader.NOT_INITIALIZED_STATUS:
                status = PassiveReader.ERROR_STATUS

            case PassiveReader.UNINITIALIZED_STATUS:
                if answer!.getSequential() != sequential - 1 {
                    status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailureEvent(error: AbstractReaderListener.READER_COMMAND_ANSWER_MISMATCH_ERROR)
                    break
                }
                
                if answer!.getData().count == 0 {
                    status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailureEvent(error: AbstractReaderListener.INVALID_PARAMETER_ERROR)
                    break
                }
                
                if answer!.getReturnCode() != PassiveReader.SUCCESSFUL_OPERATION_RETCODE {
                    status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailureEvent(error: answer!.getReturnCode())
                    break
                }
                
                if answer!.getData()[0] == PassiveReader.EPC_STANDARD {
                    HFdevice = false
                    UHFdevice = true
                    inventoryStandard = Int(answer!.getData()[0])
                } else {
                    HFdevice = true
                    UHFdevice = false
                    inventoryStandard = Int(answer!.getData()[0])
                }
                
                status = PassiveReader.READY_STATUS
                readerListenerDelegate?.connectionSuccessEvent()

            case PassiveReader.READY_STATUS:
                break
            
            case PassiveReader.PENDING_COMMAND_STATUS:
                if answer!.getSequential() == sequential - 1 {
                    if answer!.getReturnCode() != PassiveReader.SUCCESSFUL_OPERATION_RETCODE {
                        status = PassiveReader.READY_STATUS
                        if pending >= AbstractReaderListener.SOUND_COMMAND && pending <= AbstractReaderListener.ISO15693_ENCRYPTEDTUNNEL_COMMAND {
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                        } else {
                            switch pending {
                                case AbstractResponseListener.READ_COMMAND:
                                    responseListenerDelegate?.readEvent(tagID: tagID, error: answer!.getReturnCode(), data: nil)
                                
                                case AbstractResponseListener.WRITE_COMMAND:
                                    responseListenerDelegate?.writeEvent(tagID: tagID, error: answer!.getReturnCode())
                                
                                case AbstractResponseListener.LOCK_COMMAND:
                                    responseListenerDelegate?.lockEvent(tagID: tagID, error: answer!.getReturnCode())

                                case AbstractResponseListener.WRITEID_COMMAND:
                                    responseListenerDelegate?.writeIDevent(tagID: tagID, error: answer!.getReturnCode())
                                
                                case AbstractResponseListener.READ_TID_COMMAND:
                                    responseListenerDelegate?.readTIDevent(tagID: tagID, error: answer!.getReturnCode(), TID: nil)
                                
                                case AbstractResponseListener.KILL_COMMAND:
                                    responseListenerDelegate?.killEvent(tagID: tagID, error: answer!.getReturnCode())
                                
                                case AbstractResponseListener.WRITEKILLPASSWORD_COMMAND,
                                     AbstractResponseListener.WRITEACCESSPASSWORD_COMMAND:
                                    responseListenerDelegate?.writePasswordEvent(tagID: tagID, error: answer!.getReturnCode())

                                default:
                                    break
                            }
                        }
						
						break
                    }
                    
                    switch pending {
                        case AbstractReaderListener.SOUND_COMMAND,
                             AbstractReaderListener.LIGHT_COMMAND,
                             AbstractReaderListener.SET_SHUTDOWN_TIME_COMMAND,
                             AbstractReaderListener.SET_RF_POWER_COMMAND,
                             AbstractReaderListener.SET_RF_FOR_ISO15693_TUNNEL_COMMAND,
                             AbstractReaderListener.SET_ISO15693_OPTION_BITS_COMMAND,
                             AbstractReaderListener.SET_ISO15693_EXTENSION_FLAG_COMMAND,
                             AbstractReaderListener.SET_ISO15693_BITRATE_COMMAND,
                             AbstractReaderListener.SET_EPC_FREQUENCY_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                        
                        case AbstractReaderListener.SET_INVENTORY_MODE_COMMAND:
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR {
                                inventoryMode = mode
                            }
                        
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                        
                        case AbstractReaderListener.SET_INVENTORY_TYPE_COMMAND:
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR {
                                inventoryStandard = standard
                            }
                            
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                        
                        case AbstractReaderListener.SET_INVENTORY_PARAMETERS_COMMAND:
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR {
                                inventoryMode = mode
                                inventoryFeedback = feedback
                                inventoryFormat = format
                                inventoryMaxNumber = maxNumber
                                inventoryInterval = interval
                                inventoryTimeout = timeout
                                inventoryEnabled = true
                            }
                        
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                        
                        case AbstractReaderListener.TEST_AVAILABILITY_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR {
                                    readerListenerDelegate?.availabilityEvent(available: true)
                            }
                        
                        case AbstractReaderListener.GET_BATTERY_STATUS_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR && answer!.getData().count > 0 {
                                let status = answer!.getData()[0]
                                readerListenerDelegate?.batteryStatusEvent(status: Int(status))
                            }

                        case AbstractReaderListener.GET_FIRMWARE_VERSION_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR && answer!.getData().count > 0 {
                                let major = answer!.getData()[0] / 16
                                let minor = answer!.getData()[0] % 16
                                readerListenerDelegate?.firmwareVersionEvent(major: Int(major), minor: Int(minor))
                            }
                        
                        case AbstractReaderListener.GET_SHUTDOWN_TIME_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR && answer!.getData().count > 1 {
                                var time = Int(answer!.getData()[0]) * 256
                                time = time + Int(answer!.getData()[1])
                                readerListenerDelegate?.shutdownTimeEvent(time: Int(time))
                            }

                        case AbstractReaderListener.GET_RF_POWER_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR && answer!.getData().count > 1 {
                                let level = answer!.getData()[0]
                                let mode = answer!.getData()[1]
                                readerListenerDelegate?.RFpowerEvent(level: Int(level), mode: Int(mode))
                            }
                        
                        case AbstractReaderListener.GET_BATTERY_LEVEL_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR && answer!.getData().count > 1 {
                                var level: Double = Double(answer!.getData()[0]) * 256
                                level = level + Double(answer!.getData()[1])
                                level = level * (3.3 / 4095) * 2.025 // ADC -> Volt
                                readerListenerDelegate?.batteryLevelEvent(level: Float(level))
                            }

                        case AbstractReaderListener.GET_RF_FOR_ISO15693_TUNNEL_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR && answer!.getData().count > 1 {
                                let timeout = answer!.getData()[0]
                                let delay = answer!.getData()[1]
                                readerListenerDelegate?.RFforISO15693tunnelEvent(delay: Int(delay), timeout: Int(timeout))
                            }
                        
                        case AbstractReaderListener.GET_ISO15693_OPTION_BITS_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR && answer!.getData().count > 0 {
                                let bits = answer!.getData()[0]
                                readerListenerDelegate?.ISO15693optionBitsEvent(option_bits: Int(bits))
                            }
                        
                        case AbstractReaderListener.GET_ISO15693_EXTENSION_FLAG_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR && answer!.getData().count > 0 {
                                let permanent: Bool = (answer!.getData()[0] & 0x02) != 0x02
                                let flag: Bool = (answer!.getData()[0] & 0x01) == 0x01
                                readerListenerDelegate?.ISO15693extensionFlagEvent(flag: flag, permanent: permanent)
                            }

                        case AbstractReaderListener.GET_ISO15693_BITRATE_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR && answer!.getData().count > 0 {
                                let permanent: Bool = (answer!.getData()[0] & 0x02) != 0x02
                                var bitrate: Int
                                
                                if (answer!.getData()[0] & 0x01) == 0x01 {
                                    bitrate = PassiveReader.ISO15693_HIGH_BITRATE
                                } else {
                                    bitrate = PassiveReader.ISO15693_LOW_BITRATE
                                }
                                readerListenerDelegate?.ISO15693bitrateEvent(bitrate: Int(bitrate), permanent: permanent)
                            }
                        
                        case AbstractReaderListener.GET_EPC_FREQUENCY_COMMAND:
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR && answer!.getData().count > 0 {
                                let frequency: Int = Int(answer!.getData()[0])
                                readerListenerDelegate?.EPCfrequencyEvent(frequency: frequency)
                            }
                        
                        case AbstractResponseListener.READ_COMMAND:
                            responseListenerDelegate?.readEvent(tagID: tagID, error: answer!.getReturnCode(), data: answer!.getData())

                        case AbstractResponseListener.WRITE_COMMAND:
                            responseListenerDelegate?.writeEvent(tagID: tagID, error: answer!.getReturnCode())

                        case AbstractResponseListener.LOCK_COMMAND:
                            responseListenerDelegate?.lockEvent(tagID: tagID, error: answer!.getReturnCode())
                        
                        case AbstractResponseListener.WRITEID_COMMAND:
                            responseListenerDelegate?.writeIDevent(tagID: tagID, error: answer!.getReturnCode())
                        
                        case AbstractResponseListener.READ_TID_COMMAND:
                            responseListenerDelegate?.readTIDevent(tagID: tagID, error: answer!.getReturnCode(), TID: answer!.getData())
                        
                        case AbstractResponseListener.KILL_COMMAND:
                            responseListenerDelegate?.killEvent(tagID: tagID, error: answer!.getReturnCode())
                        
                        case AbstractResponseListener.WRITEKILLPASSWORD_COMMAND,
                             AbstractResponseListener.WRITEACCESSPASSWORD_COMMAND:
                            responseListenerDelegate?.writePasswordEvent(tagID: tagID, error: answer!.getReturnCode())
                        
                        default:
                            break
                    }
                } else {
                    // tunnel operation answer
                    if (tunnelAnswer != nil) && (pending == AbstractReaderListener.ISO15693_ENCRYPTEDTUNNEL_COMMAND ||
                        pending == AbstractReaderListener.ISO15693_TUNNEL_COMMAND) {
                        readerListenerDelegate?.tunnelEvent(data: tunnelAnswer)
                    } else {
                        // answer mismatch
                        readerListenerDelegate?.resultEvent(command: pending, error: AbstractReaderListener.READER_COMMAND_ANSWER_MISMATCH_ERROR)
                    }
                }
                
                status = PassiveReader.READY_STATUS

            default:
                break
        }
    }
    
    /// Informs delegate a device has been successfully disconnected
    /// - parameter device: The TxRxDevice disconnected
    public func deviceDisconnected(device: TxRxDevice) {
        readerListenerDelegate?.disconnectionEvent()
        status = PassiveReader.NOT_INITIALIZED_STATUS
        connectedDevice = nil
        
        inventoryMode = 0
        mode = 0
        inventoryFeedback = 0
        feedback = 0
        inventoryFormat = 0
        format = 0
        inventoryMaxNumber = 0
        maxNumber = 0
        inventoryInterval = 0
        interval = 0
        inventoryTimeout = 0
        timeout = 0
        inventoryStandard = 0
        standard = 0
        HFdevice = false
        UHFdevice = false
        inventoryEnabled = false
        tagID = nil
        status = 0
        sequential = 0
        pending = 0
    }
    
    /// Informs delegate a device critical error happened. NO further interaction with this TxRxDevice class should be done
    /// - parameter device: The TxRxDevice on which the error occoured
    /// - parameter error: An NSError class instance describing the error
    public func deviceError(device: TxRxDevice, error: NSError) {
        disconnect()
    }
	
    // Utility methods
    static func getStringCharAt(str: String, at: Int) -> String? {
        return PassiveReader.getStringSubString(str: str, start: at, end: at+1)
    }

    static func getStringCharAsIntAt(str: String, at: Int) -> Int {
        var subStr: String?
        
        subStr = PassiveReader.getStringSubString(str: str, start: at, end: at+1)
        return Int(subStr!)!
    }
    
    static func charToInt(char: Character) -> Int {
        return Int(String(char))!
    }
    
    static func getStringSubString(str: String, start: Int, end: Int) -> String {
        let sIndex = str.index(str.startIndex, offsetBy: start)
        let eIndex = str.index(str.startIndex, offsetBy: end)
        let range = sIndex..<eIndex
        return String(str[range])
    }
}
