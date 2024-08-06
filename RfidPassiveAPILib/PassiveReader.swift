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
import TxRxLib

/// Represents the RFID/NFC tag reader
public class PassiveReader: TxRxDeviceDataProtocol, ZhagaReaderProtocol {
    /// Passive reader internal state constants
	static internal let ERROR_STATUS: Int = -1
    static internal let NOT_INITIALIZED_STATUS: Int = 0
    static internal let UNINITIALIZED_STATUS: Int = 2
    static internal let READY_STATUS: Int = 3
    static internal let PENDING_COMMAND_STATUS: Int = 4
    
    static internal let STREAM_SUBSTATUS = 0
    static internal let SET_CMD_SUBSTATUS = 1
    static internal let CMD_SUBSTATUS = 2
    static internal let SET_STREAM_SUBSTATUS = 3
    
    static internal let STREAM_MODE = 1
    static internal let CMD_MODE = 3

	/// Passive reader commands
    static public let BEEPER_COMMAND: UInt8 = 0x01
    static public let LED_COMMAND: UInt8 = 0x02
    static public let BLE_CONFIG_COMMAND: UInt8 = 0x04;
    static public let STATUS_COMMAND: UInt8 = 0x05
    static public let MODE_COMMAND: UInt8 = 0x06
    static public let SETAUTOOFF_COMMAND: UInt8 = 0x0D
    static public let SETMODE_COMMAND: UInt8 = 0x0E
    static public let SETSTANDARD_COMMAND: UInt8 = 0x0F
    static public let EPC_INVENTORY_COMMAND: UInt8 = 0x11
    static public let EPC_WRITEID_COMMAND: UInt8 = 0x12
    static public let EPC_READ_COMMAND: UInt8 = 0x13
    static public let EPC_WRITE_COMMAND: UInt8 = 0x14
    static public let EPC_LOCK_COMMAND: UInt8 = 0x15
    static public let EPC_KILL_COMMAND: UInt8 = 0x16
    static public let EPC_SETREGISTER_COMMAND: UInt8 = 0x1E
    static public let EPC_SETPOWER_COMMAND: UInt8 = 0x1F
    static public let ISO15693_INVENTORY_COMMAND: UInt8 = 0x21
    static public let ISO15693_READ_COMMAND: UInt8 = 0x23
    static public let ISO15693_WRITE_COMMAND: UInt8 = 0x24
    static public let ISO15693_LOCK_COMMAND: UInt8 = 0x25
    static public let ISO15693_SETREGISTER_COMMAND: UInt8 = 0x2E
    static public let ISO15693_SETPOWER_COMMAND: UInt8 = 0x2F
    static public let ISO14443A_INVENTORY_COMMAND: UInt8 = 0x31
    static public let ZHAGA_DIRECT_COMMAND: UInt8 = 0x90;
    static public let ZHAGA_CONFIGURATION_COMMAND: UInt8 = 0x91;
    
    static public let BLE_DEVICE_NAME = 0x01
    static public let BLE_SECURITY_LEVEL = 0x02
    static public let BLE_ADVERTISING_INTERVAL = 0x03
    static public let BLE_TX_POWER = 0x04
    static public let BLE_CONNECTION_INTERVAL = 0x05
    static public let BLE_MAC_ADDRESS = 0x06
    static public let BLE_SLAVE_LATENCY = 0x07
    static public let BLE_SUPERVISION_TIMEOUT = 0x08
    static public let BLE_VERSION = 0x09
    static public let BLE_USER_MEMORY = 0x0A
    static public let BLE_CONNECTION_INTERVAL_AND_MTU_SIZE = 0x0B
    static public let BLE_BOOTLOADER = 0xF1
    static public let BLE_FACTORY_DEFAULT = 0xFF
    
    static public let RESET_TO_FACTORY_DEFAULT = 0xFE

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
    
    static private let EVENT_CODE: UInt8 = 0x80
    static private let BUTTON_EVENT_FEATURE_CODE: UInt8 = 0x00
    
    /// Zhaga
    static private let ZHAGA_GET_HMI_SUPPORT: UInt8 = 0x00;
    static private let ZHAGA_SET_HMI: UInt8 = 0x01
    static private let ZHAGA_SET_RF: UInt8 = 0xFD
    static private let ZHAGA_OFF: UInt8 = 0xFE
    static private let ZHAGA_REBOOT: UInt8 = 0xFF
    static private let ZHAGA_INVENTORY_SOUND: UInt8 = 0x00
    static private let ZHAGA_COMMAND_SOUND: UInt8 = 0x01
    static private let ZHAGA_ERROR_SOUND: UInt8 = 0x02
    static private let ZHAGA_INVENTORY_LED: UInt8 = 0x03
    static private let ZHAGA_COMMAND_LED: UInt8 = 0x04
    static private let ZHAGA_ERROR_LED: UInt8 = 0x05
    static private let ZHAGA_INVENTORY_VIBRATION: UInt8 = 0x06
    static private let ZHAGA_COMMAND_VIBRATION: UInt8 = 0x07
    static private let ZHAGA_ERROR_VIBRATION: UInt8 = 0x08
    static private let ZHAGA_ACTIVATE_BUTTON: UInt8 = 0xFC
    static private let ZHAGA_RF_ONOFF: UInt8 = 0xFD
    static private let ZHAGA_AUTOOFF: UInt8 = 0xFE
    static private let ZHAGA_DEFAULT: UInt8 = 0xFF
    
    ///
    ///BLE advertising -40dBm TX power
    ///
    static public let BLE_TX_POWER_MINUS_40_DBM: Int = 0x00
    ///
    ///BLE advertising -20dBm TX power
    ///
    static public let BLE_TX_POWER_MINUS_20_DBM: Int = 0x01
    ///
    ///BLE advertising -16dBm TX power
    ///
    static public let BLE_TX_POWER_MINUS_16_DBM: Int = 0x02
    ///
    ///BLE advertising -12dBm TX power
    ///
    static public let BLE_TX_POWER_MINUS_12_DBM: Int = 0x03
    ///
    ///BLE advertising -8dBm TX power
    ///
    static public let BLE_TX_POWER_MINUS_8_DBM: Int = 0x04
    ///
    ///BLE advertising -4dBm TX power
    ///
    static public let BLE_TX_POWER_MINUS_4_DBM: Int = 0x05
    ///
    ///BLE advertising 0dBm TX power
    ///
    static public let BLE_TX_POWER_0_DBM: Int = 0x06
    ///
    ///BLE advertising +2dBm TX power
    ///
    static public let BLE_TX_POWER_2_DBM: Int = 0x07
    ///
    ///BLE advertising +3dBm TX power
    ///
    static public let BLE_TX_POWER_3_DBM: Int = 0x08
    ///
    ///BLE advertising +4dBm TX power
    ///
    static public let BLE_TX_POWER_4_DBM: Int = 0x09
    ///
    ///BLE advertising +5dBm TX power
    ///
    static public let BLE_TX_POWER_5_DBM: Int = 0x0A
    ///
    ///BLE advertising +6dBm TX power
    ///
    static public let BLE_TX_POWER_6_DBM: Int = 0x0B
    ///
    ///BLE advertising +7dBm TX power
    ///
    static public let BLE_TX_POWER_7_DBM: Int = 0x0C
    ///
    ///BLE advertising +8dBm TX power
    ///
    static public let BLE_TX_POWER_8_DBM: Int = 0x0D
	
	/// PassiveReader singleton
    private static let _sharedInstance: PassiveReader = PassiveReader()
	
	/// TxRxManager instance
    internal let deviceManager: TxRxDeviceManager = TxRxDeviceManager.getInstance()
    
    /// TxRxDevice instance, the connected device
    internal var connectedDevice: TxRxDevice?
	
	/// Class delegates
	public var readerListenerDelegate: AbstractReaderListenerProtocol? = nil
    public var zhagaListenerDelegate: AbstractZhagaListenerProtocol? = nil
    public var inventoryListenerDelegate: AbstractInventoryListenerProtocol? = nil
    public var responseListenerDelegate: AbstractResponseListenerProtocol? = nil
    
    private var cmdModeCommand: String? = nil
	
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
    private var zhagaDevice: Bool = false
	
	internal var tagID: [UInt8]?
	
	internal var status: Int
    internal var sub_status: Int
    internal var sequential: Int = 0
	internal var pending: Int = 0
    
    /// EPC standard.
    public static let EPC_STANDARD:Int = 0x00
    
    /// ISO-15693 standard.
    public static let ISO15693_STANDARD:Int = 0x01
    
    /// ISO-15443A standard.
    public static let ISO14443A_STANDARD:Int = 0x02
    
    /// ISO-15693 and ISO14443A standards.
    public static let ISO15693_AND_ISO14443A_STANDARD:Int = 0x03
    
    /// Inventory scan started by doInventory() method invocation.
    public static let NORMAL_MODE:Int = 0x00
    
    /// Inventory scan started periodically (period set by PassiveReader.setInventoryParameters(Int, Int, Int))
    /// method invocation.
    public static let SCAN_ON_TIME_MODE:Int = 0x01
    
    /// Inventory scan started by the reader device button pression.
    public static let SCAN_ON_INPUT_MODE:Int = 0x02
    
    /// Sound and LED light feedback for inventory successful operation.
    public static let FEEDBACK_SOUND_AND_LIGHT:Int = 0x00
    
    /// No local feedback for inventory successful operation.
    public static let NO_FEEDBACK:Int = 0x01
    
    /// Inventory operation get ISO15693 and/or ISO14443A ID only.
    static private let ID_ONLY_FORMAT:Int = 0x01
    
    /// Inventory operation get EPC tag ID only.
    static public let EPC_ONLY_FORMAT:Int = 0x01
    
    /// Inventory operation get ECP tag ID and PC (Protocol Code).
    static public let EPC_AND_PC_FORMAT:Int = 0x03
    
    /// Inventory operation get EPC tag ID e TID (tag unique ID).
    static private let EPC_AND_TID_FORMAT:Int = 0x05
    
    /// Inventory operation get EPC tag ID, PC (Protocol Code) and TID (tag
    /// unique ID).
    static private let ECP_AND_PC_AND_TID_FORMAT:Int = 0x07
    
    /// Low battery status
    public static let LOW_BATTERY_STATUS:Int = 0x00
    
    /// Charged battery status
    public static let CHARGED_BATTERY_STATUS:Int = 0x01
    
    /// Charging battery status
    public static let CHARGING_BATTERY_STATUS:Int = 0x02
    
    /// HF reader device half RF power
    public static let HF_RF_HALF_POWER:Int = 0x00
    
    /// HF reader device full RF power
    public static let HF_RF_FULL_POWER:Int = 0x01
    
    /// HF reader device automatic RF power management
    public static let HF_RF_AUTOMATIC_POWER:Int = 0x00
    
    /// HF reader device fixed RF power
    public static let HF_RF_FIXED_POWER:Int = 0x01
    
    /// UHF reader device 0dB RF power
    public static let UHF_RF_POWER_0_DB:Int = 0x00
    
    /// UHF reader device -1dB RF power
    public static let UHF_RF_POWER_MINUS_1_DB:Int = 0x01
    
    /// UHF reader device -2dB RF power
    public static let UHF_RF_POWER_MINUS_2_DB:Int = 0x02
    
    /// UHF reader device -3dB RF power
    public static let UHF_RF_POWER_MINUS_3_DB:Int = 0x03
    
    /// UHF reader device -4dB RF power
    public static let UHF_RF_POWER_MINUS_4_DB:Int = 0x04
    
    /// UHF reader device -5dB RF power
    public static let UHF_RF_POWER_MINUS_5_DB:Int = 0x05
    
    /// UHF reader device -6dB RF power
    public static let UHF_RF_POWER_MINUS_6_DB:Int = 0x06
    
    /// UHF reader device -7dB RF power
    public static let UHF_RF_POWER_MINUS_7_DB:Int = 0x07
    
    /// UHF reader device -8dB RF power
    public static let UHF_RF_POWER_MINUS_8_DB:Int = 0x08
    
    /// UHF reader device -9dB RF power
    public static let UHF_RF_POWER_MINUS_9_DB:Int = 0x09
    
    /// UHF reader device -10dB RF power
    public static let UHF_RF_POWER_MINUS_10_DB:Int = 0x0A
    
    /// UHF reader device -11dB RF power
    public static let UHF_RF_POWER_MINUS_11_DB:Int = 0x0B
    
    /// UHF reader device -12dB RF power
    public static let UHF_RF_POWER_MINUS_12_DB:Int = 0x0C
    
    /// UHF reader device -13dB RF power
    public static let UHF_RF_POWER_MINUS_13_DB:Int = 0x0D
    
    /// UHF reader device -14dB RF power
    public static let UHF_RF_POWER_MINUS_14_DB:Int = 0x0E
    
    /// UHF reader device -15dB RF power
    public static let UHF_RF_POWER_MINUS_15_DB:Int = 0x0F
    
    /// UHF reader device -16dB RF power
    public static let UHF_RF_POWER_MINUS_16_DB:Int = 0x10
    
    /// UHF reader device -17dB RF power
    public static let UHF_RF_POWER_MINUS_17_DB:Int = 0x011
    
    /// UHF reader device -18dB RF power
    public static let UHF_RF_POWER_MINUS_18_DB:Int = 0x012
    
    /// UHF reader device -19dB RF power
    public static let UHF_RF_POWER_MINUS_19_DB:Int = 0x013
    
    /// UHF reader device automatic RF power management
    public static let UHF_RF_POWER_AUTOMATIC_MODE:Int = 0x00
    
    /// UHF reader device fixed RF power with low bias
    public static let UHF_RF_POWER_FIXED_LOW_BIAS_MODE:Int = 0x01
    
    /// UHF reader device fixed RF power with high bias
    public static let UHF_RF_POWER_FIXED_HIGH_BIAS_MODE:Int = 0x02
    
    /// ISO15693 tag with no option bits
    public static let ISO15693_OPTION_BITS_NONE:Int = 0x00
    
    /// ISO15693 tag with option bit for lock operations
    public static let ISO15693_OPTION_BITS_LOCK:Int = 0x01
    
    /// ISO15693 tag with option bit for write operations
    public static let ISO15693_OPTION_BITS_WRITE:Int = 0x02
    
    /// ISO15693 tag with option bit for read operations
    public static let ISO15693_OPTION_BITS_READ:Int = 0x04
    
    /// ISO15693 tag with option bit for inventory operations
    public static let ISO15693_OPTION_BITS_INVENTORY:Int = 0x08
    
    /// ISO15693 low bit-rate tag operations
    public static let ISO15693_LOW_BITRATE:Int = 0
    
    /// ISO15693 high bit-rate tag operations
    public static let ISO15693_HIGH_BITRATE:Int = 1
    
    /// UHF reader device RF carrier frequency from 902.75MHz to 927.5MHz
    /// (50 radio channels with frequency hopping)
    public static let RF_CARRIER_FROM_902_75_TO_927_5_MHZ:Int = 0x00
    
    /// UHF reader device RF carrier frequency from 915.25MHz to 927.5MHz
    /// (25 radio channels with frequency hopping)
    public static let RF_CARRIER_FROM_915_25_TO_927_5_MHZ:Int = 0x01
    
    /// UHF reader device RF carrier frequency 865.7MHz (no frequency hopping)
    public static let RF_CARRIER_865_7_MHZ:Int = 0x02
    
    /// UHF reader device RF carrier frequency 866.3MHz (no frequency hopping)
    public static let RF_CARRIER_866_3_MHZ:Int = 0x03
    
    /// UHF reader device RF carrier frequency 866.9MHz (no frequency hopping)
    public static let RF_CARRIER_866_9_MHZ:Int = 0x04
    
    /// UHF reader device RF carrier frequency 867.5MHz (no frequency hopping)
    public static let RF_CARRIER_867_5_MHZ:Int = 0x05
    
    /// UHF reader device RF carrier frequency from 865.7MHz to 867.5MHz
    /// (4 radio channels with frequency hopping)
    public static let RF_CARRIER_FROM_865_7_TO_867_5_MHZ:Int = 0x06
    
    /// UHF reader device RF carrier frequency 915.1MHz (no frequency hopping)
    public static let RF_CARRIER_915_1_MHZ:Int = 0x07
    
    /// UHF reader device RF carrier frequency 915.7MHz (no frequency hopping)
    public static let RF_CARRIER_915_7_MHZ:Int = 0x08
    
    /// UHF reader device RF carrier frequency 916.3MHz (no frequency hopping)
    public static let RF_CARRIER_916_3_MHZ:Int = 0x09
    
    /// UHF reader device RF carrier frequency 916.9MHz (no frequency hopping)
    public static let RF_CARRIER_916_9_MHZ:Int = 0x0A
    
    /// UHF reader device RF carrier frequency from 915.1MHz to 916.9MHz
    /// (4 radio channels with frequency hopping)
    public static let RF_CARRIER_FROM_915_1_TO_916_9_MHZ:Int = 0x0B
    
    /// UHF reader device RF carrier frequency 902.75MHz (no frequency hopping)
    public static let RF_CARRIER_902_75_MHZ:Int = 0x0C
    
    /// UHF reader device RF carrier frequency 908.75MHz (no frequency hopping)
    public static let RF_CARRIER_908_75_MHZ:Int = 0x0D
    
    /// UHF reader device RF carrier frequency 915.25MHz (no frequency hopping)
    public static let RF_CARRIER_915_25_MHZ:Int = 0x0E
    
    /// UHF reader device RF carrier frequency 921.25MHz (no frequency hopping)
    public static let RF_CARRIER_921_25_MHZ:Int = 0x0F
    
    /// UHF reader device RF carrier frequency 925.25MHz (no frequency hopping)
    public static let RF_CARRIER_925_25_MHZ:Int = 0x10
	
    public static func getInstance() -> PassiveReader {
        _sharedInstance.zhagaDevice = false
        return PassiveReader._sharedInstance
    }
    
    public static func getPassiveReaderInstance() -> PassiveReader {
        _sharedInstance.zhagaDevice = false
        return PassiveReader._sharedInstance
    }
    
    public static func getZhagaReaderInstance() -> ZhagaReaderProtocol {
        _sharedInstance.zhagaDevice = true
        return PassiveReader._sharedInstance
    }
    
	init() {
        status = PassiveReader.NOT_INITIALIZED_STATUS
        //deviceManager._delegate = self
        sequential = 0
        inventoryEnabled = false
        inventoryMode = PassiveReader.SCAN_ON_INPUT_MODE
        sub_status = PassiveReader.STREAM_SUBSTATUS
    }
    
    public static func bytesToString(bytes: [UInt8]?) -> String {
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
    
    public static func byteToHex(val: Int) -> String {
		return String(format:"%02X", val & 0xFF)
	}
	
	public static func hexToByte(hex: String) -> Int {
		return Int(strtoul(hex, nil, 16))
	}
	
	public static func hexToWord(hex: String) -> Int {
		return Int(strtoul(hex, nil, 16))
	}
    
    public static func hexStringToByte(hex: String) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: hex.count / 2)
        
        for i in 0..<hex.count/2 {
            let chunk = getStringSubString(str: hex, start: i*2, end: i*2+2)
            data[i] = UInt8(PassiveReader.hexToWord(hex: chunk))
        }
        
        return data
    }
    
    internal func buildCommand(commandCode: UInt8, parameters: [UInt8]?) -> String {
        var command: String = "$:"
        
        if parameters == nil {
            command = command + PassiveReader.byteToHex(val: 6)
            command = command + PassiveReader.byteToHex(val: sequential)
            sequential = (sequential + 1) % 256
            command = command + PassiveReader.byteToHex(val: Int(commandCode))
        } else {
            command = command + PassiveReader.byteToHex(val: 6 + 2 * parameters!.count)
            command = command + PassiveReader.byteToHex(val: sequential)
            sequential = (sequential + 1) % 256
            command = command + PassiveReader.byteToHex(val: Int(commandCode))
            for param in parameters! {
                command = command + PassiveReader.byteToHex(val: Int(param))
            }
        }
        
        return command.uppercased()
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
        
    internal func buildTunnelCommand(encrypted: Bool, parameters: [UInt8]) -> String {
        var command: String;
        
        if(encrypted == false) {
            command = "#:"
        } else {
            command = "%:"
        }
        
        for param in parameters {
            command = command + PassiveReader.byteToHex(val: Int(param))
        }
        
        return command.uppercased()
    }
    
    internal func buildZhagaTransparentCommand(parameters: [UInt8]) -> String {
        var command: String = "Z:";
        command += PassiveReader.byteToHex(val: 4 + 2 * parameters.count)
        command += PassiveReader.byteToHex(val: sequential)
        sequential = (sequential + 1) % 256
        for param in parameters {
            command += PassiveReader.byteToHex(val: Int(param))
        }
        
        return command.uppercased()
    }
    
    
    // TxRxDeviceDataProtocol implementation
    
    /// Device has been connected
    ///
    /// - parameter device: The connected TxRxDevice
    public func deviceConnected(device: TxRxDevice) {
        status = PassiveReader.UNINITIALIZED_STATUS
        sub_status = PassiveReader.STREAM_SUBSTATUS
    }
    
    /// Device has been successfully disconnected
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
    
    /// An error while connecting device happened
    ///
    /// - parameter device: The TxRxDevice on which the error occoured
    /// - parameter error: An NSError class instance describing the error
    public func deviceConnectError(device: TxRxDevice, error: NSError) {
        status = PassiveReader.ERROR_STATUS
        connectedDevice = nil
        switch error.code {
            case TxRxDeviceManagerErrors.ErrorCodes.ERROR_DEVICE_CONNECT_TIMED_OUT.rawValue:
                readerListenerDelegate?.connectionFailedEvent(error: AbstractReaderListener.READER_CONNECT_TIMEOUT_ERROR)
                zhagaListenerDelegate?.connectionFailedEvent(error: AbstractReaderListener.READER_CONNECT_TIMEOUT_ERROR)

            default:
                readerListenerDelegate?.connectionFailedEvent(error: AbstractReaderListener.READER_CONNECT_GENERIC_ERROR)
                zhagaListenerDelegate?.connectionFailedEvent(error: AbstractReaderListener.READER_CONNECT_GENERIC_ERROR)
        }
    }
    
    /// Informs a connected device is ready to operate and has been identified as a Tertium BLE device
    ///
    /// - parameter device: The TxRxDevice correctly identified
    public func deviceReady(device: TxRxDevice) {
        connectedDevice = device
        status = PassiveReader.UNINITIALIZED_STATUS
        sub_status = PassiveReader.STREAM_SUBSTATUS
        
        // REMOVE
        //print("deviceReady()\n")
        
        if (zhagaDevice == true) {
            status = PassiveReader.READY_STATUS;
            sub_status = PassiveReader.STREAM_SUBSTATUS
            HFdevice = true
            UHFdevice = false
            inventoryStandard = PassiveReader.ISO15693_STANDARD // ?
            readerListenerDelegate?.connectionSuccessEvent()
            zhagaListenerDelegate?.connectionSuccessEvent()
        } else {
            status = PassiveReader.UNINITIALIZED_STATUS;
            sub_status = PassiveReader.STREAM_SUBSTATUS;
            deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.SETSTANDARD_COMMAND, parameters: nil).data(using: String.Encoding.ascii)!)
        }

        //
    }
    
    /// The last sendData operation has succeeded
    ///
    /// - parameter device: The TxRxDevice which successfully received the data
    public func sentData(device: TxRxDevice) {
        /*
        switch (status) {
            case PassiveReader.ERROR_STATUS:
                break
                
            case PassiveReader.NOT_INITIALIZED_STATUS:
                break
         
            case PassiveReader.UNINITIALIZED_STATUS:
                break
                
            case PassiveReader.READY_STATUS:
                break
                
            case PassiveReader.PENDING_COMMAND_STATUS:
                break
        }
         */
    }

    /// The last setMode characteristic has been found
    ///
    /// - parameter device: The TxRxDevice supports setting mode
    public func setModeCharacteristicDiscovered(device: TxRxDevice) {
        // call the delegate ?
    }
    
    /// The last setMode operation has succeeded
    ///
    /// - parameter device: The TxRxDevice which successfully switched operational mode
    public func hasSetMode(device: TxRxDevice, operationalMode: UInt) {
        switch (status) {
            case PassiveReader.ERROR_STATUS,
                 PassiveReader.NOT_INITIALIZED_STATUS,
                 PassiveReader.UNINITIALIZED_STATUS:
                status = PassiveReader.ERROR_STATUS
                break
                
            case PassiveReader.READY_STATUS:
                if (operationalMode == PassiveReader.STREAM_MODE) {
                    sub_status = PassiveReader.STREAM_SUBSTATUS
                }
                else {
                    status = PassiveReader.ERROR_STATUS
                }
                break
                
            case PassiveReader.PENDING_COMMAND_STATUS:
                switch (sub_status) {
                    case PassiveReader.STREAM_SUBSTATUS,
                         PassiveReader.CMD_SUBSTATUS:
                        status = PassiveReader.ERROR_STATUS
                        break
                        
                    case PassiveReader.SET_CMD_SUBSTATUS:
                        if (operationalMode == PassiveReader.CMD_MODE) {
                            sub_status = PassiveReader.CMD_SUBSTATUS
                            deviceManager.sendData(device: connectedDevice!, data: (cmdModeCommand! + "\r\n").data(using: String.Encoding.ascii)!);
                        }
                        else {
                            status = PassiveReader.ERROR_STATUS
                        }
                        break
                        
                    case PassiveReader.SET_STREAM_SUBSTATUS:
                        if (operationalMode == PassiveReader.STREAM_MODE) {
                            sub_status = PassiveReader.STREAM_SUBSTATUS
                            status = PassiveReader.READY_STATUS
                            //readerListenerDelegate?.resultEvent(command: pending, error: AbstractReaderListener.NO_ERROR)
                            resultEvent(command_code: pending, error_code: AbstractReaderListener.NO_ERROR)
                        }
                        else {
                            status = PassiveReader.ERROR_STATUS
                        }
                        break
                        
                    default:
                        break
                }
                break
        default:
            break
        }
    }
    
    public func setModeError(device: TxRxDevice, error: NSError) {
        switch (status) {
            case PassiveReader.ERROR_STATUS,
                 PassiveReader.NOT_INITIALIZED_STATUS,
                 PassiveReader.UNINITIALIZED_STATUS,
                 PassiveReader.READY_STATUS:
                 status = PassiveReader.ERROR_STATUS
                 break
                
                case PassiveReader.PENDING_COMMAND_STATUS:
                    switch (sub_status) {
                            case PassiveReader.STREAM_SUBSTATUS,
                                 PassiveReader.CMD_SUBSTATUS,
                                 PassiveReader.SET_STREAM_SUBSTATUS:
                            status = PassiveReader.ERROR_STATUS
                            break
                        
                    case PassiveReader.SET_CMD_SUBSTATUS:
                            status = PassiveReader.READY_STATUS
                            sub_status = PassiveReader.STREAM_SUBSTATUS
                            //readerListenerDelegate?.resultEvent(command: pending, error: AbstractReaderListener.READER_DRIVER_COMMAND_CHANGE_MODE_ERROR)
                            resultEvent(command_code: pending, error_code: AbstractReaderListener.READER_DRIVER_COMMAND_CHANGE_MODE_ERROR)
                            break
                    
                    default:
                        break
                    }
                break
                    
        default:
            break
        }
    }
    
    public func setModeTimeout(device: TxRxDevice) {
        switch (status) {
            case PassiveReader.ERROR_STATUS,
                PassiveReader.NOT_INITIALIZED_STATUS,
                PassiveReader.UNINITIALIZED_STATUS,
                PassiveReader.READY_STATUS:
                status = PassiveReader.ERROR_STATUS
                break
            
            case PassiveReader.PENDING_COMMAND_STATUS:
                switch (sub_status) {
                    case PassiveReader.STREAM_SUBSTATUS,
                            PassiveReader.CMD_SUBSTATUS,
                            PassiveReader.SET_STREAM_SUBSTATUS:
                            status = PassiveReader.ERROR_STATUS
                            break
                        
                    case PassiveReader.SET_CMD_SUBSTATUS:
                            status = PassiveReader.READY_STATUS;
                            sub_status = PassiveReader.STREAM_SUBSTATUS;
                            resultEvent(command_code: pending, error_code: AbstractReaderListener.READER_DRIVER_COMMAND_CHANGE_MODE_ERROR)
                            break
                    default:
                        break
                }
            
                break
            
            default:
                break
        }
    }

    public func deviceWriteTimeout(device: TxRxDevice) {
        //print("writeTimeoutError")
        switch status {
            case PassiveReader.ERROR_STATUS,
                 PassiveReader.NOT_INITIALIZED_STATUS,
                 PassiveReader.UNINITIALIZED_STATUS:
                    status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailedEvent(error: AbstractResponseListener.READER_WRITE_TIMEOUT_ERROR)
                    zhagaListenerDelegate?.connectionFailedEvent(error: AbstractResponseListener.READER_WRITE_TIMEOUT_ERROR)
            
            //case READY_STATUS:
            case PassiveReader.PENDING_COMMAND_STATUS:
                if (sub_status == PassiveReader.CMD_SUBSTATUS) {
                    sub_status = PassiveReader.SET_STREAM_SUBSTATUS
                    deviceManager.setMode(device: connectedDevice!, mode: UInt(PassiveReader.STREAM_MODE))
                    break;
                }
                
                if (pending >= AbstractReaderListener.SOUND_COMMAND && pending <= AbstractReaderListener.ZHAGA_TRANSPARENT_COMMAND) ||
                    pending == AbstractReaderListener.SET_INVENTORY_FORMAT_COMMAND {
                    //readerListenerDelegate?.resultEvent(command: pending, error: AbstractReaderListener.READER_WRITE_TIMEOUT_ERROR)
                    //zhagaListenerDelegate?.resultEvent(command: pending, error: AbstractReaderListener.READER_WRITE_TIMEOUT_ERROR)
                    resultEvent(command_code: pending, error_code: AbstractReaderListener.READER_WRITE_TIMEOUT_ERROR)
                } else {
                    switch (pending) {
                        case AbstractZhagaListener.ZHAGA_TRANSPARENT_COMMAND:
                            zhagaListenerDelegate?.resultEvent(command: pending, error: AbstractZhagaListener.READER_WRITE_TIMEOUT_ERROR)
                            
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
    
    public func deviceReadTimeout(device: TxRxDevice) {
        //print("readTimeoutError")

        switch status {
            case PassiveReader.ERROR_STATUS,
                 PassiveReader.NOT_INITIALIZED_STATUS,
                 PassiveReader.UNINITIALIZED_STATUS:
                    status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailedEvent(error: AbstractResponseListener.READER_READ_TIMEOUT_ERROR)
                    zhagaListenerDelegate?.connectionFailedEvent(error: AbstractResponseListener.READER_READ_TIMEOUT_ERROR)

            // case READY_STATUS:
            case PassiveReader.PENDING_COMMAND_STATUS:
                if (sub_status == PassiveReader.CMD_SUBSTATUS) {
                    sub_status = PassiveReader.SET_STREAM_SUBSTATUS
                    deviceManager.setMode(device: connectedDevice!, mode: UInt(PassiveReader.STREAM_MODE))
                    break
                }
                
            if (pending >= AbstractReaderListener.SOUND_COMMAND && pending <= AbstractReaderListener.ZHAGA_TRANSPARENT_COMMAND) ||
                pending == AbstractReaderListener.SET_INVENTORY_FORMAT_COMMAND {
                    //readerListenerDelegate?.resultEvent(command: pending, error: AbstractReaderListener.READER_READ_TIMEOUT_ERROR)
                    //zhagaListenerDelegate?.resultEvent(command: pending, error: AbstractReaderListener.READER_READ_TIMEOUT_ERROR)
                    resultEvent(command_code: pending, error_code: AbstractReaderListener.READER_READ_TIMEOUT_ERROR)
                } else {
                    switch pending {
                        case AbstractZhagaListener.ZHAGA_TRANSPARENT_COMMAND:
                            zhagaListenerDelegate?.resultEvent(command: pending, error: AbstractReaderListener.READER_READ_TIMEOUT_ERROR)
                            
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
    
    /// There has been an error receiving data from device
    ///
    /// - parameter device: The TxRxDevice on which the error occoured
    /// - parameter error: An NSError class instance describing the error
    public func deviceReadError(device: TxRxDevice, error: NSError) {
        let errorCode: Int = AbstractReaderListener.READER_READ_FAIL_ERROR
        
        //print("deviceReadError")
        switch status {
            case PassiveReader.ERROR_STATUS,
                 PassiveReader.NOT_INITIALIZED_STATUS,
                 PassiveReader.UNINITIALIZED_STATUS:
                    status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailedEvent(error: errorCode)
                    zhagaListenerDelegate?.connectionFailedEvent(error: errorCode)

            case PassiveReader.PENDING_COMMAND_STATUS:
                if (sub_status == PassiveReader.CMD_SUBSTATUS) {
                    sub_status = PassiveReader.SET_STREAM_SUBSTATUS
                    deviceManager.setMode(device: connectedDevice!, mode: UInt(PassiveReader.STREAM_MODE))
                    break
                }
                
                if (pending >= AbstractReaderListener.SOUND_COMMAND && pending <= AbstractReaderListener.ZHAGA_TRANSPARENT_COMMAND) ||
                    pending == AbstractReaderListener.SET_INVENTORY_FORMAT_COMMAND {
                    //readerListenerDelegate?.resultEvent(command: pending, error: errorCode)
                    //zhagaListenerDelegate?.resultEvent(command: pending, error: errorCode)
                    resultEvent(command_code: pending, error_code: errorCode)
                } else {
                    switch(pending) {
                        case AbstractZhagaListener.ZHAGA_TRANSPARENT_COMMAND:
                            zhagaListenerDelegate?.resultEvent(command: pending, error: errorCode)
                            
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
                break
            
            default:
                break
        }
    }
    
    /// There has been an error sending data to device
    ///
    /// - parameter device: The TxRxDevice on which the error occoured
    /// - parameter error: An NSError class instance describing the error
    public func deviceWriteError(device: TxRxDevice, error: NSError) {
        let errorCode = AbstractReaderListener.READER_WRITE_FAIL_ERROR
        
        //print("deviceWriteError")
        switch status {
            case PassiveReader.ERROR_STATUS,
                PassiveReader.NOT_INITIALIZED_STATUS,
                PassiveReader.UNINITIALIZED_STATUS:
                    status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailedEvent(error: errorCode)
                    zhagaListenerDelegate?.connectionFailedEvent(error: errorCode)
                
            //case READY_STATUS:
            
            case PassiveReader.PENDING_COMMAND_STATUS:
                if (sub_status == PassiveReader.CMD_SUBSTATUS) {
                    sub_status = PassiveReader.SET_STREAM_SUBSTATUS
                    deviceManager.setMode(device: connectedDevice!, mode: UInt(PassiveReader.STREAM_MODE))
                    break;
                }
                
            if (pending >= AbstractReaderListener.SOUND_COMMAND && pending <= AbstractReaderListener.ZHAGA_TRANSPARENT_COMMAND) ||
                pending == AbstractReaderListener.SET_INVENTORY_FORMAT_COMMAND {
                    //readerListenerDelegate?.resultEvent(command: pending, error: errorCode)
                    //zhagaListenerDelegate?.resultEvent(command: pending, error: errorCode)
                    resultEvent(command_code: pending, error_code: errorCode)
                } else {
                    switch pending {
                        case AbstractZhagaListener.ZHAGA_TRANSPARENT_COMMAND:
                            zhagaListenerDelegate?.resultEvent(command: pending, error: errorCode)
                            
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
    
    /// A Tertium BLE device has sent data
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
        
        // REMOVE
        //print("receivedData()")
        
        if (sub_status == PassiveReader.CMD_SUBSTATUS) {
            if (data.count == 0) {
                /*
                readerListenerDelegate?.resultEvent(command: pending,
                                                   error: AbstractReaderListener.READER_DRIVER_COMMAND_CMD_MODE_ANSWER_ERROR)
                zhagaListenerDelegate?.resultEvent(command: pending,
                                                   error: AbstractReaderListener.READER_DRIVER_COMMAND_CMD_MODE_ANSWER_ERROR)
                 */
                resultEvent(command_code: pending, error_code: AbstractReaderListener.READER_DRIVER_COMMAND_CMD_MODE_ANSWER_ERROR)
            } else {
                dataString = String(data: data, encoding: .ascii)
                //print(dataString!);
                responseType = PassiveReader.getStringCharAt(str: dataString!, at: 0)
                if (responseType != ">") {
                    switch (pending) {
                        case AbstractReaderListener.GET_SECURITY_LEVEL_COMMAND:
                            if (responseType == "0") {
                                readerListenerDelegate?.securityLevelEvent(level: AbstractReaderListener.BLE_NO_SECURITY)
                                zhagaListenerDelegate?.securityLevelEvent(level: AbstractReaderListener.BLE_NO_SECURITY)
                            } else { // data.charAt(0) == '1'
                                readerListenerDelegate?.securityLevelEvent(level: AbstractReaderListener.BLE_LEGACY_LEVEL_2_SECURITY)
                                zhagaListenerDelegate?.securityLevelEvent(level: AbstractReaderListener.BLE_LEGACY_LEVEL_2_SECURITY)
                            }
                            break
                    
                        default:
                            break
                    }
                }
                
                sub_status = PassiveReader.SET_STREAM_SUBSTATUS;
                deviceManager.setMode(device: connectedDevice!, mode: UInt(PassiveReader.STREAM_MODE))
            }
            
            return
        }
        
        // Event handling
        if (data.count != 0) {
            if (dataString == nil) {
                dataString = String(data: data, encoding: .ascii)
            }
        }
        
        if let ds = dataString {
            if ds.count >= 2 {
                let eventResponseCheck: String = PassiveReader.getStringSubString(str: ds, start: 0, end: 2)
                if (eventResponseCheck == "> ") {
                    dataString = PassiveReader.getStringSubStringFrom(str: ds, start: 2)
                }
            }
        }
        
        if (data.count == 0) {
            status = PassiveReader.READY_STATUS
            return
        }
        
        dataString = String(data: data, encoding: .ascii)
        let splitSet = CharacterSet(arrayLiteral: "\r", "\n");
        let splitted = dataString?.components(separatedBy: splitSet)
        //print(dataString);
        if let splitted = splitted {
            for chunk in splitted {
                if chunk.count == 0 {
                    continue
                }

                if chunk.count >= 2 {
                    let eventResponseCheck: String = PassiveReader.getStringSubString(str: chunk, start: 0, end: 2)
                    if (eventResponseCheck == "> ") {
                        return
                    }
                }
                
                //print(chunk)
                responseType = PassiveReader.getStringCharAt(str: chunk, at: 0)
                switch(responseType) {
                    case "Z":
                        answer = ReaderAnswer(answer: chunk, bugfix: false)
                        break
                        
                    case "$":
                        if (pending == AbstractResponseListener.READ_COMMAND ||
                            pending == AbstractResponseListener.READ_TID_COMMAND) {
                            answer = ReaderAnswer(answer: chunk, bugfix: true)
                        } else {
                            answer = ReaderAnswer(answer: chunk, bugfix: false)
                        }
                        break
                        
                    case "#", "%":
                        tunnelAnswer = [UInt8](repeating: 0, count: ((chunk.count - 2) / 2))
                        for n in 0..<tunnelAnswer!.count {
                            tunnelAnswer![n] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: chunk, start: 2 + 2 * n, end: 2 + 2 * n + 2)))
                        }
                        break
                        
                    default:
                        // check for valid ID chars
                        for n in 0..<chunk.count {
                            let char = String(chunk[String.Index(utf16Offset: n, in: chunk)])
                            let charValue = Int(char, radix: 16)
                            if (charValue == nil || charValue! < 0) {
                                return;
                            }
                        }
                        
                        // Tag info
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
                            let separator_index = chunk.firstIndex(of: " ")
                            if separator_index == nil {
                                if chunk.count > 4 {
                                    var PC: UInt16
                                    
                                    if inventoryFormat == PassiveReader.EPC_AND_PC_FORMAT {
                                        PC = UInt16(PassiveReader.hexToWord(hex: PassiveReader.getStringSubString(str: chunk, start: 0, end: 4)))
                                        var ID = [UInt8](repeating: 0, count: (chunk.count - 4) / 2)
                                        for n in 0..<ID.count {
                                            ID[n] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: chunk, start: 4 + 2 * n, end: 4 + 2 * n + 2)))
                                        }
                                        tag = EPC_tag(PC: PC, ID: ID, passiveReader: self)
                                    } else {
                                        // EPC ONLY FORMAT
                                        var ID = [UInt8](repeating: 0, count: chunk.count / 2)
                                         for n in 0..<ID.count {
                                             ID[n] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: chunk, start: 2 * n, end: 2 * n + 2)))
                                         }
                                        tag = EPC_simple_tag(RSSI: -128, ID: ID, passiveReader: self)
                                    }
                                    inventoryListenerDelegate?.inventoryEvent(tag: tag!)
                                }
                            } else {
                                if chunk.count > 7 {
                                    var PC: UInt16 = 0
                                    var ID: [UInt8]
                                    if inventoryFormat == PassiveReader.EPC_AND_PC_FORMAT {
                                        ID = [UInt8](repeating: 0, count: (chunk.count - 7) / 2)
                                        PC = UInt16(PassiveReader.hexToWord(hex: PassiveReader.getStringSubString(str: chunk, start: 0, end: 4)))
                                        for n in 0..<ID.count {
                                            ID[n] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: chunk, start: 4 + 2 * n, end: 4 + 2 * n + 2)))
                                        }
                                    } else {
                                        ID = [UInt8](repeating: 0, count: chunk.count / 2)
                                        for n in 0..<ID.count {
                                            ID[n] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: chunk, start: 2 * n, end: 2 * n + 2)))
                                        }
                                    }
                                    var rssi: String
                                    var tmp: Int
                                    
                                    rssi = PassiveReader.getStringSubString(str: chunk, start: separator_index!.utf16Offset(in: chunk) + 1, end: separator_index!.utf16Offset(in: chunk) + 1 + 2)
                                    tmp = PassiveReader.hexToWord(hex: rssi)
                                    var RSSI: Int16
                                    if tmp < 127 {
                                        RSSI = Int16(tmp)
                                    } else {
                                        RSSI = Int16(tmp - 256)
                                    }
                                    
                                    if inventoryFormat == PassiveReader.EPC_AND_PC_FORMAT {
                                        tag = EPC_tag(RSSI: RSSI, PC: PC, ID: ID, passiveReader: self)
                                    } else {
                                        // EPC_ONLY_FORMAT
                                        tag = EPC_simple_tag(RSSI: RSSI, ID: ID, passiveReader: self)
                                    }
                                    inventoryListenerDelegate?.inventoryEvent(tag: tag!)
                                }
                            }
                        }
                }
            }
        }
        
        switch (status) {
            case PassiveReader.ERROR_STATUS,
                 PassiveReader.NOT_INITIALIZED_STATUS:
                status = PassiveReader.ERROR_STATUS

            case PassiveReader.UNINITIALIZED_STATUS:
                if (answer == nil || answer!.isValid() == false) {
                    status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailedEvent(error: AbstractReaderListener.READER_ANSWER_WRONG_FORMAT_ERROR)
                    zhagaListenerDelegate?.connectionFailedEvent(error: AbstractZhagaListener.READER_ANSWER_WRONG_FORMAT_ERROR)
                    break
                }

                //if answer!.getSequential() != sequential - 1 {
                if answer!.getSequential() != (sequential == 0 ? 25 : sequential-1) {
                    status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailedEvent(error: AbstractReaderListener.READER_COMMAND_ANSWER_MISMATCH_ERROR)
                    break
                }
                
                if answer!.getData().count == 0 {
                    status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailedEvent(error: AbstractReaderListener.INVALID_PARAMETER_ERROR)
                    break
                }
                
                if answer!.getReturnCode() != PassiveReader.SUCCESSFUL_OPERATION_RETCODE {
                    status = PassiveReader.ERROR_STATUS
                    readerListenerDelegate?.connectionFailedEvent(error: answer!.getReturnCode())
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
                if (answer != nil && answer!.isValid() == false) {
                    status = PassiveReader.READY_STATUS
                    //readerListenerDelegate?.resultEvent(command: pending, error: AbstractReaderListener.READER_ANSWER_WRONG_FORMAT_ERROR)
                    //zhagaListenerDelegate?.resultEvent(command: pending, error: AbstractZhagaListener.READER_ANSWER_WRONG_FORMAT_ERROR)
                    resultEvent(command_code: pending, error_code: AbstractZhagaListener.READER_ANSWER_WRONG_FORMAT_ERROR)
                    break
                }
                //if answer != nil && answer!.getSequential() == sequential - 1 {
                if answer != nil && answer!.getSequential() == (sequential==0 ? 255 : sequential-1) {
                    if answer!.getReturnCode() != PassiveReader.SUCCESSFUL_OPERATION_RETCODE && pending != AbstractZhagaListener.ZHAGA_TRANSPARENT_COMMAND {
                        status = PassiveReader.READY_STATUS
                        if (pending >= AbstractReaderListener.SOUND_COMMAND && pending <= AbstractZhagaListener.ZHAGA_TRANSPARENT_COMMAND) ||
                            pending == AbstractReaderListener.SET_INVENTORY_FORMAT_COMMAND {
                            //readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            //zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            resultEvent(command_code: pending, error_code: answer!.getReturnCode())
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
                             AbstractReaderListener.SET_EPC_FREQUENCY_COMMAND,
                             AbstractReaderListener.SET_ADVERTISING_INTERVAL_COMMAND,
                             AbstractReaderListener.SET_BLE_POWER_COMMAND,
                             AbstractReaderListener.SET_CONNECTION_INTERVAL_COMMAND,
                             AbstractReaderListener.SET_SLAVE_LATENCY_COMMAND,
                             AbstractReaderListener.SET_SUPERVISION_TIMEOUT_COMMAND,
                             AbstractReaderListener.WRITE_USER_MEMORY_COMMAND,
                             AbstractReaderListener.DEFAULT_BLE_CONFIGURATION_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_HMI_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_RF_COMMAND,
                             AbstractZhagaListener.ZHAGA_OFF_COMMAND,
                             AbstractZhagaListener.ZHAGA_REBOOT_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_INVENTORY_SOUND_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_COMMAND_SOUND_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_ERROR_SOUND_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_INVENTORY_LED_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_COMMAND_LED_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_ERROR_LED_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_INVENTORY_VIBRATION_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_COMMAND_VIBRATION_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_ERROR_VIBRATION_COMMAND,
                             AbstractZhagaListener.ZHAGA_ACTIVATE_BUTTON_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_RF_ONOFF_COMMAND,
                             AbstractZhagaListener.ZHAGA_SET_AUTOOFF_COMMAND,
                             AbstractZhagaListener.ZHAGA_DEFAULT_CONFIG_COMMAND,
                             AbstractReaderListener.SET_SECURITY_LEVEL_COMMAND,
                             AbstractReaderListener.SET_DEVICE_NAME_COMMAND:
                            resultEvent(command_code: pending, error_code: answer!.getReturnCode())
                        
                        case AbstractReaderListener.SET_INVENTORY_FORMAT_COMMAND:
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR {
                                inventoryFormat = format
                            }
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractReaderListener.DEFAULT_SETUP_COMMAND:
                            inventoryStandard = PassiveReader.ISO15693_STANDARD
                            inventoryMode = PassiveReader.SCAN_ON_INPUT_MODE
                            inventoryTimeout = 5 // 500ms

                            resultEvent(command_code: pending, error_code: answer!.getReturnCode())

                        case AbstractReaderListener.SET_INVENTORY_MODE_COMMAND:
                            /*
                            if answer!.getReturnCode() == AbstractReaderListener.NO_ERROR {
                                inventoryMode = mode
                            }
                            */                            
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
                                inventoryInterval = interval / 100
                                inventoryTimeout = timeout / 100
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
                        
                        case AbstractReaderListener.GET_SECURITY_LEVEL_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 0) {
                                let level: Int = Int(answer!.getData()[0])
                                readerListenerDelegate?.securityLevelEvent(level: level);
                            }
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractReaderListener.GET_DEVICE_NAME_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 0) {
                                let name: String = answer!.getDataAsString()
                                zhagaListenerDelegate?.nameEvent(device_name: name)
                                readerListenerDelegate?.nameEvent(device_name: name)
                            }
                            
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractReaderListener.GET_ADVERTISING_INTERVAL_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 1) {
                                var interval: Int = Int(answer!.getData()[0])*256
                                interval = interval + Int(answer!.getData()[1])
                                readerListenerDelegate?.advertisingIntervalEvent(advertising_interval: interval*625/1000);
                            }
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode());
                            
                        case AbstractReaderListener.GET_BLE_POWER_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 0) {
                                let power: Int = Int(answer!.getData()[0])
                                readerListenerDelegate?.BLEpowerEvent(BLE_power: power);
                            }
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())

                        case AbstractReaderListener.GET_CONNECTION_INTERVAL_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 3) {
                                var min_interval: Float = Float(Int((answer!.getData()[0]))*256)
                                min_interval += Float(Int(answer!.getData()[1]))
                                var max_interval: Float = Float(Int((answer!.getData()[2]))*256)
                                max_interval += Float(Int(answer!.getData()[3]))
                                readerListenerDelegate?.connectionIntervalEvent(min_interval: min_interval*1.25, max_interval: max_interval*1.25)
                            }
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractReaderListener.GET_CONNECTION_INTERVAL_AND_MTU_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 2) {
                                var interval: Float = Float(Int((answer!.getData()[0]))*256)
                                interval += Float(Int((answer!.getData()[1])))
                                let MTU: Int = Int(answer!.getData()[2])
                                readerListenerDelegate?.connectionIntervalAndMTUevent(connection_interval: interval*1.25, MTU: MTU)
                            }
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                                    
                        case AbstractReaderListener.GET_MAC_ADDRESS_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 5) {
                                readerListenerDelegate?.MACaddressEvent(MAC_address: answer!.getData())
                            }
                            readerListenerDelegate?.resultEvent(command:  pending, error: answer!.getReturnCode())

                        case AbstractReaderListener.GET_SLAVE_LATENCY_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 1) {
                                var latency: Int = Int(answer!.getData()[0])*256
                                latency += Int(answer!.getData()[1])
                                readerListenerDelegate?.slaveLatencyEvent(slave_latency: latency);
                            }
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())

                        case AbstractReaderListener.GET_SUPERVISION_TIMEOUT_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 1) {
                                var timeout: Int = Int(answer!.getData()[0])*256
                                timeout += Int(answer!.getData()[1])
                                readerListenerDelegate?.supervisionTimeoutEvent(supervision_timeout: timeout*10)
                            }
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())

                        case AbstractReaderListener.GET_BLE_FIRMWARE_VERSION_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 1) {
                                let major: Int = Int(answer!.getData()[1]) / 16
                                let minor: Int = Int(answer!.getData()[1]) % 16
                                readerListenerDelegate?.BLEfirmwareVersionEvent(major: major, minor: minor)
                            }
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                        
                        case AbstractReaderListener.READ_USER_MEMORY_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 63) {
                                readerListenerDelegate?.userMemoryEvent(data_block: answer!.getData())
                            }
                            readerListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_RF_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 0) {
                                zhagaListenerDelegate?.RFevent(RF_on: (answer!.getData()[0] == 0x01 ? true : false))
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                        
                        case AbstractZhagaListener.ZHAGA_GET_HMI_SUPPORT_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 2) {
                                let LED_color: Int = Int(answer!.getData()[0])
                                let sound_vibration: Int = Int(answer!.getData()[1])
                                let button_number: Int = Int(answer!.getData()[2])
                                zhagaListenerDelegate?.HMIevent(LED_color: LED_color, sound_vibration: sound_vibration, button_number: button_number)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                                                    
                        case AbstractZhagaListener.ZHAGA_GET_INVENTORY_SOUND_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 4) {
                                var frequency: Int = Int(answer!.getData()[0])*256
                                frequency += Int(answer!.getData()[1])
                                let on_time = Int(answer!.getData()[2])*10
                                let off_time = Int(answer!.getData()[3])*10
                                let repetition = Int(answer!.getData()[4])
                                zhagaListenerDelegate?.soundForInventoryEvent(sound_frequency: frequency, sound_on_time: on_time, sound_off_time: off_time, sound_repetition: repetition)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_COMMAND_SOUND_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 4) {
                                var frequency: Int = Int(answer!.getData()[0])*256
                                frequency += Int(answer!.getData()[1])
                                let on_time: Int = Int(answer!.getData()[2])*10
                                let off_time: Int = Int(answer!.getData()[3])*10
                                let repetition: Int = Int(answer!.getData()[4])
                                zhagaListenerDelegate?.soundForCommandEvent(sound_frequency: frequency, sound_on_time: on_time, sound_off_time: off_time, sound_repetition: repetition)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_ERROR_SOUND_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 4) {
                                var frequency: Int = Int(answer!.getData()[0])*256
                                frequency += Int(answer!.getData()[1])
                                let on_time: Int = Int(answer!.getData()[2])*10
                                let off_time: Int = Int(answer!.getData()[3])*10
                                let repetition: Int = Int(answer!.getData()[4])
                                zhagaListenerDelegate?.soundForErrorEvent(sound_frequency: frequency, sound_on_time: on_time, sound_off_time: off_time, sound_repetition: repetition)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_INVENTORY_LED_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 3) {
                                let color: Int = Int(answer!.getData()[0])
                                let on_time: Int = Int(answer!.getData()[1])*10
                                let off_time: Int = Int(answer!.getData()[2])*10
                                let repetition: Int = Int(answer!.getData()[3])
                                zhagaListenerDelegate?.LEDforInventoryEvent(light_color: color, light_on_time: on_time, light_off_time: off_time, light_repetition: repetition)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_COMMAND_LED_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 3) {
                                let color: Int = Int(answer!.getData()[0])
                                let on_time: Int = Int(answer!.getData()[1])*10
                                let off_time: Int = Int(answer!.getData()[2])*10
                                let repetition: Int = Int(answer!.getData()[3])
                                zhagaListenerDelegate?.LEDforCommandEvent(light_color: color, light_on_time: on_time, light_off_time: off_time, light_repetition: repetition)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_ERROR_LED_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 3) {
                                let color: Int = Int(answer!.getData()[0])
                                let on_time: Int = Int(answer!.getData()[1])*10
                                let off_time: Int = Int(answer!.getData()[2])*10
                                let repetition: Int = Int(answer!.getData()[3])
                                zhagaListenerDelegate?.LEDforErrorEvent(light_color: color, light_on_time: on_time, light_off_time: off_time, light_repetition: repetition)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_INVENTORY_VIBRATION_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 2) {
                                let on_time: Int = Int(answer!.getData()[0])*10
                                let off_time: Int = Int(answer!.getData()[1])*10
                                let repetition: Int = Int(answer!.getData()[2])
                                zhagaListenerDelegate?.vibrationForInventoryEvent(vibration_on_time: on_time, vibration_off_time: off_time, vibration_repetition: repetition)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_COMMAND_VIBRATION_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 2) {
                                let on_time: Int = Int(answer!.getData()[0])*10
                                let off_time: Int = Int(answer!.getData()[1])*10
                                let repetition: Int = Int(answer!.getData()[2])
                                zhagaListenerDelegate?.vibrationForCommandEvent(vibration_on_time: on_time, vibration_off_time: off_time, vibration_repetition: repetition)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_ERROR_VIBRATION_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 2) {
                                let on_time: Int = Int(answer!.getData()[0])*10
                                let off_time: Int = Int(answer!.getData()[1])*10
                                let repetition: Int = Int(answer!.getData()[2])
                                zhagaListenerDelegate?.vibrationForErrorEvent(vibration_on_time: on_time, vibration_off_time: off_time, vibration_repetition: repetition)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_ACTIVATED_BUTTON_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 0) {
                                let button: Int = Int(answer!.getData()[0])
                                zhagaListenerDelegate?.activatedButtonEvent(activated_button: button)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_RF_ONOFF_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 4) {
                                let power: Int = Int(answer!.getData()[0])
                                var timeout: Int = Int(answer!.getData()[1])*256
                                timeout += Int(answer!.getData()[2])
                                var preactivation: Int = Int(answer!.getData()[3])*256
                                preactivation += Int(answer!.getData()[4])
                                zhagaListenerDelegate?.RFonOffEvent(RF_power: power, RF_off_timeout: timeout, RF_on_preactivation: preactivation)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_GET_AUTOOFF_COMMAND:
                            if (answer!.getReturnCode() == AbstractReaderListener.NO_ERROR &&
                                    answer!.getData().count > 1) {
                                var time: Int = Int(answer!.getData()[0])*256
                                time += Int(answer!.getData()[1])
                                zhagaListenerDelegate?.autoOffEvent(OFF_time: time)
                            }
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())
                            
                        case AbstractZhagaListener.ZHAGA_TRANSPARENT_COMMAND:
                            zhagaListenerDelegate?.transparentEvent(answer: answer!.getData());
                            zhagaListenerDelegate?.resultEvent(command: pending, error: answer!.getReturnCode())

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
                        if (pending >= AbstractReaderListener.SOUND_COMMAND &&
                            pending <= AbstractReaderListener.ZHAGA_TRANSPARENT_COMMAND) ||
                            pending == AbstractReaderListener.SET_INVENTORY_FORMAT_COMMAND {
                            resultEvent(command_code: pending, error_code: AbstractReaderListener.READER_DRIVER_COMMAND_ANSWER_MISMATCH_ERROR);
                        } else {
                            switch (pending) {
                                case AbstractResponseListener.READ_COMMAND:
                                    responseListenerDelegate?.readEvent(tagID: tagID, error: AbstractResponseListener.READER_DRIVER_COMMAND_ANSWER_MISMATCH_ERROR, data: nil);

                                case AbstractResponseListener.WRITE_COMMAND:
                                        responseListenerDelegate?.writeEvent(tagID: tagID, error: AbstractResponseListener.READER_DRIVER_COMMAND_ANSWER_MISMATCH_ERROR);

                                case AbstractResponseListener.LOCK_COMMAND:
                                        responseListenerDelegate?.lockEvent(tagID: tagID, error: AbstractResponseListener.READER_DRIVER_COMMAND_ANSWER_MISMATCH_ERROR);

                                case AbstractResponseListener.WRITEID_COMMAND:
                                        responseListenerDelegate?.writeIDevent(tagID: tagID, error: AbstractResponseListener.READER_DRIVER_COMMAND_ANSWER_MISMATCH_ERROR);

                                case AbstractResponseListener.READ_TID_COMMAND:
                                    responseListenerDelegate?.readTIDevent(tagID: tagID, error: AbstractResponseListener.READER_DRIVER_COMMAND_ANSWER_MISMATCH_ERROR, TID: nil);

                                case AbstractResponseListener.KILL_COMMAND:
                                        responseListenerDelegate?.killEvent(tagID: tagID, error: AbstractResponseListener.READER_DRIVER_COMMAND_ANSWER_MISMATCH_ERROR);

                                case AbstractResponseListener.WRITEKILLPASSWORD_COMMAND,
                                         AbstractResponseListener.WRITEACCESSPASSWORD_COMMAND:
                                        responseListenerDelegate?.writePasswordEvent(tagID: tagID, error: AbstractResponseListener.READER_DRIVER_COMMAND_ANSWER_MISMATCH_ERROR);
                                    
                                default:
                                    break;
                            }
                        }
                    }
                }
                
                status = PassiveReader.READY_STATUS

            default:
                break
        }
    }
  
    /// We received event data
    ///
    /// - parameter device: The TxRxDevice which successfully switched operational mode
    /// - parameter data: The data received
    public func receivedEventData(device: TxRxDevice, data: Data)
    {
        var event: ReaderEvent? = nil
        
        let eventString = String(data: data, encoding: .ascii)        
        let splitSet = CharacterSet(arrayLiteral: "\r", "\n");
        let splitted = eventString?.components(separatedBy: splitSet)
        if let splitted = splitted {
            for chunk in splitted {
                if chunk.count == 0 {
                    continue
                }
                
                let responseType = PassiveReader.getStringCharAt(str: chunk, at: 0)
                if (responseType == "I") {
                    event = ReaderEvent(event: chunk)
                } else {
                    return
                }
                
                switch (status) {
                    case PassiveReader.ERROR_STATUS,
                         PassiveReader.NOT_INITIALIZED_STATUS,
                         PassiveReader.UNINITIALIZED_STATUS:
                        break
                        
                    case PassiveReader.READY_STATUS,
                         PassiveReader.PENDING_COMMAND_STATUS:
                        if (event != nil && event?.isValid() == true) {
                            if (event!.getEventCode() == PassiveReader.EVENT_CODE) {
                                zhagaListenerDelegate?.deviceEventEvent(event_number: event!.getNumber(), event_code: event!.getFeatureCode())
                                if (event!.getFeatureCode() == PassiveReader.BUTTON_EVENT_FEATURE_CODE &&
                                    event!.getData().count > 1) {
                                    let button: Int = Int(event!.getData()[0])
                                    let time: Int = Int(event!.getData()[1])
                                    zhagaListenerDelegate?.buttonEvent(button: button, time: time*20);
                                }
                            }
                        }
                        break
                        
                    default:
                        break
                }
            }
        }
    }

    /// A device critical error happened. NO further interaction with this TxRxDevice class should be done
    /// - parameter device: The TxRxDevice on which the error occoured
    /// - parameter error: An NSError class instance describing the error
    public func deviceError(device: TxRxDevice, error: NSError) {
        disconnect()
    }
    
    ///
    /// Get the reader device security level.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link AbstractReaderListener#securityLevelEvent(int) securityLevelEvent} methods
    /// invocation.
    public func getSecurityLevel() {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_SECURITY_LEVEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return;
        }
        
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_SECURITY_LEVEL_COMMAND
        if (deviceManager.isTxRxAckme(device: connectedDevice!)) {
            sub_status = PassiveReader.SET_CMD_SUBSTATUS
            cmdModeCommand = "get bl e e"
            deviceManager.setMode(device: connectedDevice!, mode: UInt(PassiveReader.CMD_MODE))
        } else {
            let parameters = [UInt8(PassiveReader.BLE_SECURITY_LEVEL)]
            deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
        }
        
        //print("Pending command")
    }
    
    class ReaderAnswer {
        private var valid: Bool = false
        private var length: Int = 0
        private var sequential: Int = 0
        private var returnCode: Int = 0xFF
        private var data = [UInt8](repeating: 0, count: 0)

        init(answer: String, bugfix: Bool) {
            length = PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: answer, start: 2, end: 4))
            if length >= 6 {
                length = PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: answer, start: 2, end: 4))
                if (bugfix && (length % 2 != 0)) {
                    length = length + 1
                }
                
                if length == answer.count - 2 {
                    // $:0800000
                    sequential = PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: answer, start: 4, end: 6))
                    returnCode = PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: answer, start: 6, end: 8))
                    data = [UInt8](repeating: 0, count: (length - 5) / 2)
                    for n in 0..<data.count {
                        data[n] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: answer, start: 8 + 2 * n, end: 8 + 2 * n + 2)))
                    }
                    valid = true
                }
            }
        }
        
        func isValid() -> Bool {
            return valid
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
        
        func getDataAsString() -> String {
            return String(bytes: data, encoding: .ascii)!
        }
    }
    
    class ReaderEvent {
        private var valid: Bool = false
        private var length: Int = 0
        private var number: Int = 0
        private var eventCode: Int = 0
        private var featureCode: Int = 0
        private var data = [UInt8](repeating: 0, count: 0)
        
        init(event: String) {
            length = PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: event, start: 2, end: 4))
            if length >= 8 {
                if length == event.count - 2 {
                    // $:0800000
                    number = PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: event, start: 4, end: 6))
                    eventCode = PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: event, start: 6, end: 8))
                    featureCode = PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: event, start: 8, end: 10))
                    data = [UInt8](repeating: 0, count: (length - 8) / 2)
                    for n in 0..<data.count {
                        data[n] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: event, start: 10 + 2 * n, end: 10 + 2 * n + 2)))
                    }
                    valid = true
                }
            }
        }
        
        func isValid() -> Bool {
            return valid
        }

        func getLength() -> Int {
            return length
        }

        func getNumber() -> Int {
            return number
        }
        
        func getEventCode() -> Int {
            return eventCode
        }

        func getFeatureCode() -> Int {
            return featureCode
        }

        func getData() -> [UInt8] {
            return data
        }
    }
    
    ///
    /// Set the reader device security level.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} method
    /// invocation.
    /// The new security level will be set after a power off/on cycle of the
    /// reader device.
    ///
    /// - parameter level - the new security level
    public func setSecurityLevel(level: Int) {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_SECURITY_LEVEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        if (deviceManager.isTxRxAckme(device: connectedDevice!)) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_SECURITY_LEVEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
           return
        }
        
        if (level < AbstractReaderListener.BLE_NO_SECURITY || level > AbstractReaderListener.BLE_LESC_LEVEL_2_SECURITY) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_SECURITY_LEVEL_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
           return
        }
        
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_SECURITY_LEVEL_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_SECURITY_LEVEL), UInt8(level)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
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
	/// - parameter command - the command to send to the tag
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
        deviceManager.sendData(device: connectedDevice!, data: buildTunnelCommand(encrypted: true, parameters: frame).data(using: String.Encoding.ascii)!)
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
        deviceManager.sendData(device: connectedDevice!, data: buildTunnelCommand(encrypted: false, parameters: command).data(using: String.Encoding.ascii)!)
    }
    

    ///
    /// Set the reader device name.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} or via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// The new configuration will be active after a reader device reset or power off/on cycle
    ///
    /// - parameter device_name -  the reader name
    ///
    public func setName(device_name: String)
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_DEVICE_NAME_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR);
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.SET_DEVICE_NAME_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR);
           return
        }
        
        if (device_name.count > 40 ) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_DEVICE_NAME_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.SET_DEVICE_NAME_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_DEVICE_NAME_COMMAND
        var command: String = "$:"
        command += PassiveReader.byteToHex(val: 6 + 2 + 2 * device_name.count) // ?
        command += PassiveReader.byteToHex(val: sequential)
        sequential = (sequential+1) % 256
        command += PassiveReader.byteToHex(val: Int(PassiveReader.BLE_CONFIG_COMMAND))
        command += PassiveReader.byteToHex(val: Int(PassiveReader.BLE_DEVICE_NAME))
        let name: [UInt8] = Array(device_name.utf8)
        for n in 0..<device_name.count {
            let tmp: String = PassiveReader.byteToHex(val: Int(name[n]))
            command += tmp
        }
        
        deviceManager.sendData(device: connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }
    
    ///
    /// Get the reader device name.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#nameEvent(String) nameEvent} or via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#nameEvent(String) nameEvent}methods
    /// invocation.
    public func getName()
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_DEVICE_NAME_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR);
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.GET_DEVICE_NAME_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR);
           return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_DEVICE_NAME_COMMAND
        let parameter = [UInt8(PassiveReader.BLE_DEVICE_NAME)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
    }
    

    ///
    /// Set the BLE advertising interval.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} method
    /// invocation.
    ///
    /// The new configuration will be active after a reader device reset or power off/on cycle
    ///
    /// parameter - interval  the BLE advertising interval value (ms)
    public func setAdvertisingInterval(interval: Int)
    {
        var advertising_interval: [UInt8] = [UInt8](repeating: 0, count: 2)
        
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_ADVERTISING_INTERVAL_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR);
           return
        }
        
        if (interval < 20 || interval > 10240) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_ADVERTISING_INTERVAL_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR);
            return
        }
        let in_interval = interval*1000/625
        let tmp: String = String(format: "%04X", in_interval)
        advertising_interval[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        advertising_interval[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_ADVERTISING_INTERVAL_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_ADVERTISING_INTERVAL), advertising_interval[0], advertising_interval[1]]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }
    
    ///
    /// Get the BLE advertising_interval.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#advertisingIntervalEvent(int) advertisingIntervalEvent} methods
    /// invocation.
    public func getAdvertisingInterval()
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_ADVERTISING_INTERVAL_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_ADVERTISING_INTERVAL_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_ADVERTISING_INTERVAL)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Set the BLE advertising TX power.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} method
    /// invocation.
    ///
    /// The new configuration will be active after a reader device reset or power off/on cycle
    ///
    /// @param power  the BLE advertising TX power value
    ///
    public func setBLEpower(power: Int)
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_BLE_POWER_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (power < PassiveReader.BLE_TX_POWER_MINUS_40_DBM || power > PassiveReader.BLE_TX_POWER_8_DBM) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_BLE_POWER_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_BLE_POWER_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_TX_POWER), UInt8(power)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Get the BLE advertising TX power.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#BLEpowerEvent(int) BLEpowerEvent} methods
    /// invocation.
    ///
    public func getBLEpower()
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_BLE_POWER_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_BLE_POWER_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_TX_POWER)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Set the BLE connection interval.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} method
    /// invocation.
    ///
    /// The new configuration will be active after a reader device reset or power off/on cycle
    ///
    /// @param min_interval  the BLE connection interval minimum value (ms)
    /// @param max_interval  the BLE connection interval maximum value (ms)
    ///
    public func setConnectionInterval(min_interval: Float, max_interval: Float)
    {
        var min_connection_interval = [UInt8](repeating: 0, count: 2)
        var max_connection_interval = [UInt8](repeating: 0, count: 2)
        var interval: Int
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_CONNECTION_INTERVAL_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (min_interval < 7.5 || min_interval > 4000) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_CONNECTION_INTERVAL_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        if (max_interval < 8 || max_interval > 4000) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_CONNECTION_INTERVAL_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        if (min_interval >= max_interval) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_CONNECTION_INTERVAL_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        let int_min_interval = min_interval / 1.25
        interval = Int(int_min_interval)
        var tmp = String(format: "%04X", interval)
        min_connection_interval[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        min_connection_interval[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        let int_max_interval = max_interval / 1.25
        interval = Int(int_max_interval)
        tmp = String(format: "%04X", interval)
        max_connection_interval[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        max_connection_interval[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_CONNECTION_INTERVAL_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_CONNECTION_INTERVAL), min_connection_interval[0], min_connection_interval[1], max_connection_interval[0], max_connection_interval[1]]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Get the BLE connection interval.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#connectionIntervalEvent(float, float) connectionIntervalEvent} methods
    /// invocation.
    ///
    public func getConnectionInterval()
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_CONNECTION_INTERVAL_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_CONNECTION_INTERVAL_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_CONNECTION_INTERVAL)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Get the BLE negoziated connection interval and MTU.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#connectionIntervalAndMTUevent(float, int) connectionIntervalAndMTUevent} methods
    /// invocation.
    ///
    public func getConnectionIntervalAndMTU()
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_CONNECTION_INTERVAL_AND_MTU_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_CONNECTION_INTERVAL_AND_MTU_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_CONNECTION_INTERVAL_AND_MTU_SIZE)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Get the BLE device MAC address.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#MACaddressEvent(byte[]) MACaddressEvent} methods
    /// invocation.
    ///
    public func getMACaddress()
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_MAC_ADDRESS_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_MAC_ADDRESS_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_MAC_ADDRESS)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Set the BLE slave latency.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} method
    /// invocation.
    ///
    /// The new configuration will be active after a reader device reset or power off/on cycle
    ///
    /// @param latency  the BLE slave latency value
    ///
    public func setSlaveLatency(latency: Int)
    {
        var slave_latency = [UInt8](repeating: 0, count: 2)
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_SLAVE_LATENCY_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (latency < 0 || latency > 499) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_SLAVE_LATENCY_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        let tmp = String(format: "%04X", latency)
        slave_latency[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        slave_latency[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_SLAVE_LATENCY_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_SLAVE_LATENCY), slave_latency[0], slave_latency[1]]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Get the BLE slave latency.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#slaveLatencyEvent(int) slaveLatencyEvent} methods
    /// invocation.
    ///
    public func getSlaveLatency()
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_SLAVE_LATENCY_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_SLAVE_LATENCY_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_SLAVE_LATENCY)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Set the BLE supervision timeout.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} method
    /// invocation.
    ///
    /// The new configuration will be active after a reader device reset or power off/on cycle
    ///
    /// @param timeout  the BLE supervision timeout value (ms)
    ///
    public func setSupervisionTimeout(timeout: Int)
    {
        var supervision_timeout = [UInt8](repeating: 0, count: 2)
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_SUPERVISION_TIMEOUT_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (timeout < 10 || timeout > 32000) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_SUPERVISION_TIMEOUT_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        let int_timeout = timeout / 10
        let tmp = String(format: "%04X", int_timeout)
        supervision_timeout[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        supervision_timeout[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_SUPERVISION_TIMEOUT_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_SUPERVISION_TIMEOUT), supervision_timeout[0], supervision_timeout[1]]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Get the BLE supervision timeout.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#supervisionTimeoutEvent(int) supervisionTimeoutEvent} methods
    /// invocation.
    ///
    public func getSupervisionTimeout()
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_SUPERVISION_TIMEOUT_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_SUPERVISION_TIMEOUT_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_SUPERVISION_TIMEOUT)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Get the BLE MCU firmware version.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#BLEfirmwareVersionEvent(int, int) BLEfirmwareVersionEvent} methods
    /// invocation.
    ///
    public func getBLEfirmwareVersion()
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.GET_BLE_FIRMWARE_VERSION_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.GET_BLE_FIRMWARE_VERSION_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_VERSION)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Write the reader user memory.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} method
    /// invocation.
    ///
    /// If the data size N is less than 64 bytes, the bytes from N to 64 are set to 0
    ///
    /// @param block  the user memory 64-byte block to write (0/1)
    /// @param data  the user memory data to write (byte-array, maximum size: 64 bytes)
    ///
    public func writeUserMemory(block: Int, data: [UInt8])
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.WRITE_USER_MEMORY_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (block < 0 || block > 1) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.WRITE_USER_MEMORY_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        if (data.count > 64) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.WRITE_USER_MEMORY_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.WRITE_USER_MEMORY_COMMAND
        var command = "$:"
        command += PassiveReader.byteToHex(val: 6 + 4 + 2*data.count) // ?
        command += PassiveReader.byteToHex(val: sequential)
        sequential += 1
        command += PassiveReader.byteToHex(val: Int(PassiveReader.BLE_CONFIG_COMMAND))
        command += PassiveReader.byteToHex(val: PassiveReader.BLE_USER_MEMORY)
        command += PassiveReader.byteToHex(val: block)
        for n in 0..<data.count {
            let tmp = PassiveReader.byteToHex(val: Int(data[n]))
            command += tmp
        }
        
        deviceManager.sendData(device: connectedDevice!, data: command.data(using: String.Encoding.ascii)!)
    }

    ///
    /// Read the reader user memory.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#userMemoryEvent(byte[]) userMemoryEvent} methods
    /// invocation.
    ///
    /// @param block  the user memory 64-byte block to write (0/1)
    ///
    public func readUserMemory(block: Int)
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.READ_USER_MEMORY_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (block < 0 || block > 1) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.READ_USER_MEMORY_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.READ_USER_MEMORY_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_USER_MEMORY), UInt8(block)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Reset the reader device.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} or via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// @param bootloader enter FUOTA (Firmware Update On The Air) mode
    ///
    public func reset(bootloader: Bool)
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.RESET_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.RESET_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        
        if (UHFdevice) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.RESET_COMMAND, error: AbstractReaderListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.RESET_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        
        if (!bootloader) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.RESET_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.RESET_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.RESET_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_BOOTLOADER)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    ///
    /// Reset the reader device to BLE factory default configuration.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} or via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// The new configuration will be active after a reader device reset or power off/on cycle
    ///
    /// @param mode  reset BLE configuration mode (0: reset none, 1: reset all, 2: reset all except device name)
    /// @param erase_bonding erase bonding list of BLE devices
    ///
    public func defaultBLEconfiguration(mode: Int, erase_bonding: Bool)
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.DEFAULT_BLE_CONFIGURATION_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.DEFAULT_BLE_CONFIGURATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        if (deviceManager.isTxRxAckme(device: connectedDevice!)) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.DEFAULT_BLE_CONFIGURATION_COMMAND, error: AbstractReaderListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.DEFAULT_BLE_CONFIGURATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        
        if (mode < 0 || mode > 2) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.DEFAULT_BLE_CONFIGURATION_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.DEFAULT_BLE_CONFIGURATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.DEFAULT_BLE_CONFIGURATION_COMMAND
        let parameters = [UInt8(PassiveReader.BLE_FACTORY_DEFAULT), UInt8(mode), UInt8(erase_bonding ? 1 : 0)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.BLE_CONFIG_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getHMIsupport()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_HMI_SUPPORT_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_HMI_SUPPORT_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_HMI_SUPPORT_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_GET_HMI_SUPPORT)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_DIRECT_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setHMI(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int,
                       light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int,
                       vibration_on_time: Int, vibration_off_time: Int, int vibration_repetition: Int)
    {
        var frequency = [UInt8](repeating: 0, count: 2)
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_HMI_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_HMI_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        
        if (sound_frequency < 40 || sound_frequency > 20000 ||
            sound_on_time < 0 || sound_on_time > 2550 || sound_off_time < 0 || sound_off_time > 2550 || sound_repetition < 0 || sound_repetition > 255 ||
            light_color < 0 || light_color > 255 ||
            light_on_time < 0 || light_on_time > 2550 || light_off_time < 0 || light_off_time > 2550 || light_repetition < 0 || light_repetition > 255 ||
            vibration_on_time < 0 || vibration_on_time > 2550 || vibration_off_time < 0 || vibration_off_time > 2550 || vibration_repetition < 0 || vibration_repetition > 255) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_HMI_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_HMI_COMMAND
        let tmp = String(format: "%04X", sound_frequency)
        frequency[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        frequency[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        let parameters = [UInt8(PassiveReader.ZHAGA_SET_HMI), frequency[0], frequency[1], UInt8(sound_on_time/10), UInt8(sound_off_time/10), UInt8(sound_repetition), UInt8(light_color), UInt8(light_on_time/10), UInt8(light_off_time/10), UInt8(light_repetition),
            UInt8(vibration_on_time/10), UInt8(vibration_off_time/10), UInt8(vibration_repetition)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_DIRECT_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setRF(RF_on: Bool)
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_RF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_RF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_RF_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_SET_RF), UInt8(RF_on ? 1 : 0)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_DIRECT_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getRF()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_RF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_RF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_RF_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_SET_RF)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_DIRECT_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func off()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_OFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_OFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_OFF_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_OFF)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_DIRECT_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func reboot()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_REBOOT_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_REBOOT_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_REBOOT_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_REBOOT), UInt8(0xFF)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_DIRECT_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setSoundForInventory(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int)
    {
        var frequency = [UInt8](repeating: 0, count: 2)
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_INVENTORY_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_INVENTORY_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        if (sound_frequency < 40 || sound_frequency > 20000 ||
            sound_on_time < 0 || sound_on_time > 2550 || sound_off_time < 0 || sound_off_time > 2550 || sound_repetition < 0 || sound_repetition > 255) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_INVENTORY_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_INVENTORY_SOUND_COMMAND
        let tmp = String(format: "%04X", sound_frequency)
        frequency[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        frequency[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        let parameters = [UInt8(PassiveReader.ZHAGA_INVENTORY_SOUND), UInt8(frequency[0]), UInt8(frequency[1]), UInt8(sound_on_time/10), UInt8(sound_off_time/10), UInt8(sound_repetition)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getSoundForInventory()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_INVENTORY_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_INVENTORY_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_INVENTORY_SOUND_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_INVENTORY_SOUND)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setSoundForCommand(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int)
    {
        var frequency = [UInt8](repeating: 0, count: 2)
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_COMMAND_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_COMMAND_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        if (sound_frequency < 40 || sound_frequency > 20000 ||
            sound_on_time < 0 || sound_on_time > 2550 || sound_off_time < 0 || sound_off_time > 2550 || sound_repetition < 0 || sound_repetition > 255) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_COMMAND_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_COMMAND_SOUND_COMMAND
        let tmp = String(format: "%04X", sound_frequency)
        frequency[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        frequency[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        let parameters = [UInt8(PassiveReader.ZHAGA_COMMAND_SOUND), frequency[0], frequency[1], UInt8(sound_on_time/10), UInt8(sound_off_time/10), UInt8(sound_repetition)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getSoundForCommand()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_COMMAND_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_COMMAND_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_COMMAND_SOUND_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_COMMAND_SOUND)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setSoundForError(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int)
    {
        var frequency = [UInt8](repeating: 0, count: 2)
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_ERROR_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_ERROR_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        if (sound_frequency < 40 || sound_frequency > 20000 ||
            sound_on_time < 0 || sound_on_time > 2550 || sound_off_time < 0 || sound_off_time > 2550 || sound_repetition < 0 || sound_repetition > 255) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_ERROR_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_ERROR_SOUND_COMMAND
        let tmp = String(format: "%04X", sound_frequency)
        frequency[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        frequency[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        let parameters = [UInt8(PassiveReader.ZHAGA_ERROR_SOUND), frequency[0], frequency[1], UInt8(sound_on_time/10), UInt8(sound_off_time/10), UInt8(sound_repetition)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getSoundForError()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_ERROR_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_ERROR_SOUND_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_ERROR_SOUND_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_ERROR_SOUND)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setLEDforInventory(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int)
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_INVENTORY_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_INVENTORY_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        
        if (light_color < 0 || light_color > 255 || light_on_time < 0 || light_on_time > 2550 || light_off_time < 0 || light_off_time > 2550 || light_repetition < 0 || light_repetition > 255) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_INVENTORY_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_INVENTORY_LED_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_INVENTORY_LED), UInt8(light_color), UInt8(light_on_time/10), UInt8(light_off_time/10), UInt8(light_repetition)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getLEDforInventory()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_INVENTORY_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_INVENTORY_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_INVENTORY_LED_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_INVENTORY_LED)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setLEDforCommand(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int)
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_COMMAND_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_COMMAND_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        if (light_color < 0 || light_color > 255 || light_on_time < 0 || light_on_time > 2550 || light_off_time < 0 || light_off_time > 2550 || light_repetition < 0 || light_repetition > 255) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_COMMAND_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_COMMAND_LED_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_INVENTORY_LED), UInt8(light_color), UInt8(light_on_time/10), UInt8(light_off_time/10), UInt8(light_repetition)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getLEDforCommand()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_COMMAND_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_COMMAND_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_COMMAND_LED_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_COMMAND_LED)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setLEDforError(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int)
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_ERROR_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_ERROR_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        if (light_color < 0 || light_color > 255 || light_on_time < 0 || light_on_time > 2550 || light_off_time < 0 || light_off_time > 2550 || light_repetition < 0 || light_repetition > 255) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_ERROR_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_ERROR_LED_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_COMMAND_LED), UInt8(light_color), UInt8(light_on_time/10), UInt8(light_off_time/10), UInt8(light_repetition)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getLEDforError()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_ERROR_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_ERROR_LED_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_ERROR_LED_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_ERROR_LED)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setVibrationForInventory(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int)
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_INVENTORY_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_INVENTORY_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        if (vibration_on_time < 0 || vibration_on_time > 2550 || vibration_off_time < 0 || vibration_off_time > 2550 || vibration_repetition < 0 || vibration_repetition > 255) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_INVENTORY_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_INVENTORY_VIBRATION_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_INVENTORY_VIBRATION), UInt8(vibration_on_time/10), UInt8(vibration_off_time/10), UInt8(vibration_repetition)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getVibrationForInventory()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_INVENTORY_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_INVENTORY_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_INVENTORY_VIBRATION_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_INVENTORY_VIBRATION)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setVibrationForCommand(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int)
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_COMMAND_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_COMMAND_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        if (vibration_on_time < 0 || vibration_on_time > 2550 || vibration_off_time < 0 || vibration_off_time > 2550 || vibration_repetition < 0 || vibration_repetition > 255) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_COMMAND_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_COMMAND_VIBRATION_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_COMMAND_VIBRATION), UInt8(vibration_on_time/10), UInt8(vibration_off_time/10), UInt8(vibration_repetition)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getVibrationForCommand()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_COMMAND_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_COMMAND_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_COMMAND_VIBRATION_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_COMMAND_VIBRATION)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setVibrationForError(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int)
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_ERROR_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_ERROR_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        if (vibration_on_time < 0 || vibration_on_time > 2550 || vibration_off_time < 0 || vibration_off_time > 2550 || vibration_repetition < 0 || vibration_repetition > 255) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_ERROR_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_ERROR_VIBRATION_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_ERROR_VIBRATION), UInt8(vibration_on_time/10), UInt8(vibration_off_time/10), UInt8(vibration_repetition)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getVibrationForError()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_ERROR_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_ERROR_VIBRATION_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_ERROR_VIBRATION_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_ERROR_VIBRATION)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func activateButton(activated_button: Int)
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_ACTIVATE_BUTTON_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_ACTIVATE_BUTTON_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        if (activated_button < 0 || activated_button > 255) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_ACTIVATE_BUTTON_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_ACTIVATE_BUTTON_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_ACTIVATE_BUTTON), UInt8(activated_button)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getActivatedButton()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_ACTIVATED_BUTTON_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_ACTIVATED_BUTTON_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_ACTIVATED_BUTTON_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_ACTIVATE_BUTTON)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setRFonOff(RF_power: Int, RF_off_timeout: Int, RF_on_preactivation: Int)
    {
        var timeout = [UInt8](repeating: 0, count: 2)
        var preactivation = [UInt8](repeating: 0, count: 2)
        
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_RF_ONOFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_RF_ONOFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        if (RF_power < 0 || RF_power > 100 ||
            RF_off_timeout < 0 || RF_off_timeout > 65535 ||
            RF_on_preactivation < 0 || RF_on_preactivation > 65535) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_RF_ONOFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_RF_ONOFF_COMMAND
        var tmp = String(format: "%04X", RF_off_timeout)
        timeout[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        timeout[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        tmp = String(format: "%04X", RF_on_preactivation)
        preactivation[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        preactivation[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        let parameters = [UInt8(PassiveReader.ZHAGA_RF_ONOFF), UInt8(RF_power), timeout[0], timeout[1], preactivation[0], preactivation[1]]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getRFonOff()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_RF_ONOFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_RF_ONOFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_RF_ONOFF_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_RF_ONOFF)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func setAutoOff(OFF_time: Int)
    {
        var time = [UInt8](repeating: 0, count: 2)
                
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_AUTOOFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_AUTOOFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        if (OFF_time < 0 || OFF_time > 65535) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_SET_AUTOOFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_SET_AUTOOFF_COMMAND
        let tmp = String(format: "%04X", OFF_time)
        time[0] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 0, end: 2)))
        time[1] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: tmp, start: 2, end: 4)))
        let parameters = [UInt8(PassiveReader.ZHAGA_AUTOOFF), time[0], time[1]]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func getAutoOff()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_AUTOOFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_GET_AUTOOFF_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_GET_AUTOOFF_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_AUTOOFF)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func defaultConfiguration()
    {
        if (status != PassiveReader.READY_STATUS) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_DEFAULT_CONFIG_COMMAND, error: AbstractZhagaListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_DEFAULT_CONFIG_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractZhagaListener.ZHAGA_DEFAULT_CONFIG_COMMAND
        let parameters = [UInt8(PassiveReader.ZHAGA_DEFAULT), UInt8(0x00)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ZHAGA_CONFIGURATION_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }

    public func transparent(command: [UInt8])
    {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.ZHAGA_TRANSPARENT_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        if (UHFdevice) {
            zhagaListenerDelegate?.resultEvent(command: AbstractZhagaListener.ZHAGA_TRANSPARENT_COMMAND, error: AbstractZhagaListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.ZHAGA_TRANSPARENT_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildZhagaTransparentCommand(parameters: command).data(using: String.Encoding.ascii)!)
    }
    
	/// Closes the reader driver
    public func close() {
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
	/// - parameter reader_address: The device name
    public func connect(reader_address: String) {
        // TODO: implement caching system and keep UUIDs
        var device: TxRxDevice?
        
        disconnect()
        device = deviceManager.deviceFromDeviceName(name: reader_address)
		if device == nil {
			readerListenerDelegate?.connectionFailedEvent(error: AbstractReaderListener.READER_CONNECT_DEVICE_NOT_FOUND_ERROR)
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
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_SETREGISTER_COMMAND, parameters: parameter).data(using: String.Encoding.ascii)!)
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
    public func isAvailable(device_address: String) -> Bool {
        var name: String?
        
        name = deviceManager.getDeviceName(device: connectedDevice!)
        return name == device_address
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
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.LED_COMMAND, parameters: led).data(using: String.Encoding.ascii)!)
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
    
    ///
    /// Set the inventory response format for the UHF reader device.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} method
    /// invocation.
    ///
    /// - parameter format - the inventory response format
    public func setInventoryFormat(format: Int)
    {
        var data = [UInt8](repeating: 0, count: 6)
        if status != PassiveReader.READY_STATUS {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_INVENTORY_MODE_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
            return
        }
        
        if isHF() {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_INVENTORY_FORMAT_COMMAND, error: AbstractReaderListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        
        if format != PassiveReader.EPC_AND_PC_FORMAT && format != PassiveReader.EPC_ONLY_FORMAT {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.SET_INVENTORY_FORMAT_COMMAND, error: AbstractReaderListener.READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR)
            return
        }
        
        self.format = format
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_INVENTORY_FORMAT_COMMAND
        
        data[0] = UInt8(mode)
        data[1] = UInt8(feedback)
        data[2] = UInt8(format)
        data[3] = UInt8(maxNumber)
        data[4] = UInt8(timeout / 100)
        data[5] = UInt8(interval / 100)
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.SETMODE_COMMAND, parameters: data).data(using: String.Encoding.ascii)!)
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
    /// - parameter timeout  - the inventory scan time (milliseconds: 100-25500)
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
        
        if timeout < 100 || timeout > 25500 {
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
            format = PassiveReader.EPC_ONLY_FORMAT
        }
        
        maxNumber = 0
        mode = PassiveReader.SCAN_ON_INPUT_MODE
        self.timeout = timeout
        self.interval = interval
        
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
        
        let parameters = [UInt8(PassiveReader.REGISTER_RF_PARAMETERS_FOR_TUNNEL_MODE), UInt8(timeout), UInt8(delay)];
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.SET_RF_FOR_ISO15693_TUNNEL_COMMAND
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.ISO15693_SETREGISTER_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
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
        var cmdCode: UInt8
        
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
    
    ///
    /// Reset the reader device parameters to factory default setup.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} method invocation.
    public func defaultSetup() {
        if (status != PassiveReader.READY_STATUS) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.DEFAULT_SETUP_COMMAND, error: AbstractReaderListener.READER_DRIVER_WRONG_STATUS_ERROR)
           return
        }
        
        if (isUHF() == true) {
            readerListenerDelegate?.resultEvent(command: AbstractReaderListener.DEFAULT_SETUP_COMMAND, error: AbstractReaderListener.READER_DRIVER_UNKNOW_COMMAND_ERROR)
            return
        }
        
        status = PassiveReader.PENDING_COMMAND_STATUS
        pending = AbstractReaderListener.DEFAULT_SETUP_COMMAND
        let parameters = [UInt8(PassiveReader.RESET_TO_FACTORY_DEFAULT)]
        deviceManager.sendData(device: connectedDevice!, data: buildCommand(commandCode: PassiveReader.SETSTANDARD_COMMAND, parameters: parameters).data(using: String.Encoding.ascii)!)
    }
    
    // Utility methods
    public static func getStringCharAt(str: String, at: Int) -> String? {
        return PassiveReader.getStringSubString(str: str, start: at, end: at+1)
    }

    public static func getStringCharAsIntAt(str: String, at: Int) -> Int {
        var subStr: String?
        
        subStr = PassiveReader.getStringSubString(str: str, start: at, end: at+1)
        return Int(subStr!)!
    }
    
    public static func charToInt(char: Character) -> Int {
        return Int(String(char))!
    }
    
    private func resultEvent(command_code: Int, error_code: Int) {
        if (command_code >= AbstractReaderListener.SOUND_COMMAND &&
            command_code < AbstractReaderListener.SET_SECURITY_LEVEL_COMMAND) {
            readerListenerDelegate?.resultEvent(command: command_code, error: error_code)
            return;
        }
        if (command_code >= AbstractReaderListener.SET_SECURITY_LEVEL_COMMAND &&
            command_code < AbstractReaderListener.SET_ADVERTISING_INTERVAL_COMMAND) {
            readerListenerDelegate?.resultEvent(command: command_code, error: error_code)
            zhagaListenerDelegate?.resultEvent(command: command_code, error: error_code)
            return
        }
        if ((command_code >= AbstractReaderListener.SET_ADVERTISING_INTERVAL_COMMAND &&
            command_code < AbstractReaderListener.RESET_COMMAND) ||
            command_code == AbstractReaderListener.SET_INVENTORY_FORMAT_COMMAND) {
            readerListenerDelegate?.resultEvent(command: command_code, error: error_code)
            return
        }
        if (command_code >= AbstractReaderListener.RESET_COMMAND &&
            command_code < AbstractReaderListener.ZHAGA_GET_HMI_SUPPORT_COMMAND) {
            readerListenerDelegate?.resultEvent(command: command_code, error: error_code)
            zhagaListenerDelegate?.resultEvent(command: command_code, error: error_code)
            return
        }
        if (command_code >= AbstractReaderListener.ZHAGA_GET_HMI_SUPPORT_COMMAND &&
            command_code < AbstractReaderListener.ZHAGA_TRANSPARENT_COMMAND) {
            zhagaListenerDelegate?.resultEvent(command: command_code, error: error_code)
            return
        }
    }
    
    public static func getStringSubString(str: String, start: Int, end: Int) -> String {
        let sIndex = str.index(str.startIndex, offsetBy: start)
        let eIndex = str.index(str.startIndex, offsetBy: end)
        let range = sIndex..<eIndex
        return String(str[range])
    }

    public static func getStringSubStringFrom(str: String, start: Int) -> String {
        let sIndex = str.index(str.startIndex, offsetBy: start)
        let eIndex = str.endIndex
        let range = sIndex..<eIndex
        return String(str[range])
    }
}
