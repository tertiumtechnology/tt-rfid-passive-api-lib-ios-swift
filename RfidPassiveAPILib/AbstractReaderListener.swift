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

public class AbstractReaderListener
{   
    /// Inventory scan started by {@link PassiveReader#doInventory()
    /// doInventory} method invocation.
    static let NORMAL_MODE: Int = 0x00
    
    /// Inventory scan started periodically (period set by {@link
    /// PassiveReader#setInventoryParameters(int, int, int) setInventoryParameters}
    /// method invocation.
    static let SCAN_ON_TIME_MODE: Int = 0x01
    
    /// Inventory scan started by the reader device button pression
    static let SCAN_ON_INPUT_MODE: Int = 0x02
    
    /// {@link PassiveReader#sound(int, int, int, int, int) sound} command.
    static let SOUND_COMMAND: Int = 0
    
    /// {@link PassiveReader#light(boolean, int) light} command.
    static let LIGHT_COMMAND: Int = 1
    
    /// {@link PassiveReader#getBatteryStatus() getBatteryStatus} command.
    public static let GET_BATTERY_STATUS_COMMAND: Int = 2
    
    /// {@link PassiveReader#getFirmwareVersion() getFirmwareVersion} command.
    public static let GET_FIRMWARE_VERSION_COMMAND: Int = 3
    
    /// {@link PassiveReader#setShutdownTime(int) setShutdownTime} command.
    public static let SET_SHUTDOWN_TIME_COMMAND: Int = 4
    
    /// {@link PassiveReader#getShutdownTime() getShutdownTime} command.
    public static let GET_SHUTDOWN_TIME_COMMAND: Int = 5
    
    /// {@link PassiveReader#setInventoryMode(int) setInventoryMode} command.
    public static let SET_INVENTORY_MODE_COMMAND: Int = 6
    
    /// {@link PassiveReader#setInventoryParameters(int, int, int)
    /// setInventoryParameters} command.
    public static let SET_INVENTORY_PARAMETERS_COMMAND: Int = 7
    
    /// {@link PassiveReader#setRFpower(int, int) setRFpower} command.
    public static let SET_RF_POWER_COMMAND: Int = 8
    
    /// {@link PassiveReader#getRFpower() getRFpower} command.
    public static let GET_RF_POWER_COMMAND: Int = 9
    
    /// {@link PassiveReader#doInventory() } command.
    public static let INVENTORY_COMMAND: Int = 10
    
    /// {@link PassiveReader#setRFforISO15693tunnel(int, int)
    /// setRFforISO15693tunnel} command.
    public static let SET_RF_FOR_ISO15693_TUNNEL_COMMAND: Int = 11
    
    /// {@link PassiveReader#getRFforISO15693tunnel() getRFforISO15693tunnel}
    /// command.
    public static let GET_RF_FOR_ISO15693_TUNNEL_COMMAND: Int = 12
    
    /// {@link PassiveReader#setISO15693optionBits(int) setISO15693optionBits}
    /// command.
    public static let SET_ISO15693_OPTION_BITS_COMMAND: Int = 13
    
    /// {@link PassiveReader#getISO15693optionBits() getISO15693optionBits}
    /// command.
    public static let GET_ISO15693_OPTION_BITS_COMMAND: Int = 14
    
    /// {@link PassiveReader#setISO15693extensionFlag(boolean, boolean)
    /// setISO15693extensionFlag} command.
    public static let SET_ISO15693_EXTENSION_FLAG_COMMAND: Int = 15
    
    /// {@link PassiveReader#getISO15693extensionFlag() getISO15693extensionFlag}
    /// command.
    public static let GET_ISO15693_EXTENSION_FLAG_COMMAND: Int = 16
    
    /// {@link PassiveReader#setISO15693bitrate(int, boolean) setISO15693bitrate}
    /// command.
    public static let SET_ISO15693_BITRATE_COMMAND: Int = 17
    
    /// {@link PassiveReader#getISO15693bitrate() getISO15693bitrate} command
    public static let GET_ISO15693_BITRATE_COMMAND: Int = 18
    
    /// {@link PassiveReader#setEPCfrequency(int) setEPCfrequency} command.
    public static let SET_EPC_FREQUENCY_COMMAND: Int = 19
    
    /// {@link PassiveReader#getEPCfrequency() getEPCfrequency} command.
    public static let GET_EPC_FREQUENCY_COMMAND: Int = 20
    
    /// {@link PassiveReader#testAvailability() testAvailability} command.
    public static let TEST_AVAILABILITY_COMMAND: Int = 21
    
    /// {@link PassiveReader#getBatteryLevel() getBatteryLevel} command.
    public static let GET_BATTERY_LEVEL_COMMAND: Int = 22
    
    /// {@link PassiveReader#setInventoryType(int) setInventoryType} command.
    public static let SET_INVENTORY_TYPE_COMMAND: Int = 23
    
    /// {@link PassiveReader#ISO15693tunnel(byte[]) ISO15693tunnel} command.
    public static let ISO15693_TUNNEL_COMMAND: Int = 24
    
    /// {@link PassiveReader#ISO15693encryptedTunnel(byte, byte[])
    /// ISO15693encryptedTunnel} command.
    public static let ISO15693_ENCRYPTEDTUNNEL_COMMAND: Int = 25
    
    /// {@link PassiveReader#isHF() isHF} command.
    public static let IS_HF_COMMAND: Int = 26
    
    /// {@link PassiveReader#isUHF() isUHF} command.
    public static let IS_UHF_COMMAND: Int = 27
    
    ///
    /// @link PassiveReader#setSecurityLevel(int) setSecurityLevel} command.
    ///
    public static let SET_SECURITY_LEVEL_COMMAND: Int = 28
    
    ///
    /// {@link PassiveReader#getSecurityLevel() getSecurityLevel} command.
    ///
    public static let GET_SECURITY_LEVEL_COMMAND: Int = 29

    /// Successful command code (no error).
    static let NO_ERROR: Int = 0x00
    
    /// Invalid memory location or bank error code.
    static let INVALID_MEMORY_ERROR: Int = 0x01
    
    /// Locked memory location or bank error code.
    static let LOCKED_MEMORY_ERROR: Int = 0x02
    
    /// Inventory error code.
    static let INVENTORY_ERROR: Int = 0x03
    
    /// Invalid command parameter error code.
    static let INVALID_PARAMETER_ERROR: Int = 0x0C
    
    /// Timeout error code.
    static let TIMEOUT_ERROR: Int = 0x0D
    
    /// Not implemented command error code.
    static let UNKNOWN_COMMAND_ERROR: Int = 0x0E
    
    /// Invalid command error code.
    static let INVALID_COMMAND_ERROR: Int = 0x0F
    
    /// Reader write command failed error code.
    static let READER_WRITE_FAIL_ERROR: Int = 0x10
    
    /// Reader write command timeout error code.
    static let READER_WRITE_TIMEOUT_ERROR: Int = 0x11
    
    /// Reader read answer failed error code.
    static let READER_READ_FAIL_ERROR: Int = 0x12
    
    /// Reader read answer timeout error code.
    static let READER_READ_TIMEOUT_ERROR: Int = 0x13
    
    /// Reader command/answer mismatch error code.
    static let READER_COMMAND_ANSWER_MISMATCH_ERROR: Int = 0x14
    
    /// Reader connection generic error.
    static let READER_CONNECT_GENERIC_ERROR: Int = 0x15
    
    /// Reader connection timeout error.
    static let READER_CONNECT_TIMEOUT_ERROR: Int = 0x16
    
    /// Reader connection error in discovering service.
     
    static let READER_CONNECT_UNKNOW_SERVICE_ERROR: Int = 0x17
    
    /// Reader connection error: device not found.
     
    static let READER_CONNECT_DEVICE_NOT_FOUND_ERROR: Int = 0x18
    
    /// Reader connection error: invalid BT adapter.
     
    static let READER_CONNECT_INVALID_BLUETOOTH_ADAPTER_ERROR: Int = 0x19
    
    /// Reader connection error: invalid device address.
     
    static let READER_CONNECT_INVALID_DEVICE_ADDRESS_ERROR: Int = 0x1A
    
    /// Reader disconnection error: BLE not initialized.
     
    static let READER_DISCONNECT_BLE_NOT_INITIALIZED_ERROR: Int = 0x1B
    
    /// Reader disconnection error: invalid BT adapter.
     
    static let READER_DISCONNECT_INVALID_BLUETOOTH_ADAPTER_ERROR: Int = 0x1C
    
    /// Reader read error: BLE device error.
     
    static let READER_READ_BLE_DEVICE_ERROR: Int = 0x1D
    
    /// Reader read error: invalid TX characteristic.
     
    static let READER_READ_INVALID_TX_CHARACTERISTIC_ERROR: Int = 0x1E
    
    /// Reader write error: BLE device error.
     
    static let READER_WRITE_BLE_DEVICE_ERROR: Int = 0x1F
    
    /// Reader write error: invalid RX characteristic.
     
    static let READER_WRITE_INVALID_RX_CHARACTERISTIC_ERROR: Int = 0x20
    
    /// Reader write error: previous operation in progress.
     
    static let READER_WRITE_OPERATION_IN_PROGRESS_ERROR: Int = 0x21
    
    /// Reader driver not ready error.
     
    static let READER_DRIVER_NOT_READY_ERROR: Int = 0x22
    
    /// Reader driver wrong status error.
     
    static let READER_DRIVER_WRONG_STATUS_ERROR: Int = 0x23
    
    /// Reader driver un-know command error.
     
    static let READER_DRIVER_UNKNOW_COMMAND_ERROR: Int = 0x24
    
    /// Reader driver command wrong parameter error.
    static let READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR: Int = 0x25
    
    ///
    /// Reader driver command answer mismatch error.
    ///
    static let READER_DRIVER_COMMAND_ANSWER_MISMATCH_ERROR: Int = 0x26
    
    ///
    /// Reader driver change-mode error.
    ///
    static let READER_DRIVER_COMMAND_CHANGE_MODE_ERROR: Int = 0x27
    
    ///
    /// Reader command mode answer error.
    ///
    static let READER_DRIVER_COMMAND_CMD_MODE_ANSWER_ERROR: Int = 0x28
    
    ///
    /// Reader set-mode error: BLE device error.
    ///
    static let READER_SET_MODE_BLE_DEVICE_ERROR: Int = 0x29
    
    ///
    /// Reader set-mode error: invalid MODE characteristic.
    ///
    static let READER_SET_MODE_INVALID_CHARACTERISTIC_ERROR: Int = 0x2A
    
    ///
    /// Reader set-mode error: previous operation in progress.
    ///
    static let READER_SET_MODE_OPERATION_IN_PROGRESS_ERROR: Int = 0x2B

    /// Low battery status
    static let LOW_BATTERY_STATUS: Int = 0x00
    
    /// Charged battery status
    static let CHARGED_BATTERY_STATUS: Int = 0x01
    
    /// Charging battery status
    static let CHARGING_BATTERY_STATUS: Int = 0x02

    /// HF reader device half RF power
    static let HF_RF_HALF_POWER: Int = 0x00
    
    /// HF reader device full RF power
    static let HF_RF_FULL_POWER: Int = 0x01
    
    /// HF reader device automatic RF power management
    static let HF_RF_AUTOMATIC_POWER: Int = 0x00
    
    /// HF reader device fixed RF power
    static let HF_RF_FIXED_POWER: Int = 0x01

    /// UHF reader device 0dB RF power
    static let UHF_RF_POWER_0_DB: Int = 0x00
    
    /// UHF reader device -1dB RF power
    static let UHF_RF_POWER_MINUS_1_DB: Int = 0x01
    
    /// UHF reader device -2dB RF power
    static let UHF_RF_POWER_MINUS_2_DB: Int = 0x02
    
    /// UHF reader device -3dB RF power
    static let UHF_RF_POWER_MINUS_3_DB: Int = 0x03
    
    /// UHF reader device -4dB RF power
     
    static let UHF_RF_POWER_MINUS_4_DB: Int = 0x04
    
    /// UHF reader device -5dB RF power
     
    static let UHF_RF_POWER_MINUS_5_DB: Int = 0x05
    
    /// UHF reader device -6dB RF power
     
    static let UHF_RF_POWER_MINUS_6_DB: Int = 0x06
    
    /// UHF reader device -7dB RF power
     
    static let UHF_RF_POWER_MINUS_7_DB: Int = 0x07
    
    /// UHF reader device -8dB RF power
     
    static let UHF_RF_POWER_MINUS_8_DB: Int = 0x08
    
    /// UHF reader device -9dB RF power
     
    static let UHF_RF_POWER_MINUS_9_DB: Int = 0x09
    
    /// UHF reader device -10dB RF power
     
    static let UHF_RF_POWER_MINUS_10_DB: Int = 0x0A
    
    /// UHF reader device -11dB RF power
     
    static let UHF_RF_POWER_MINUS_11_DB: Int = 0x0B
    
    /// UHF reader device -12dB RF power
     
    static let UHF_RF_POWER_MINUS_12_DB: Int = 0x0C
    
    /// UHF reader device -13dB RF power
     
    static let UHF_RF_POWER_MINUS_13_DB: Int = 0x0D
    
    /// UHF reader device -14dB RF power
     
    static let UHF_RF_POWER_MINUS_14_DB: Int = 0x0E
    
    /// UHF reader device -15dB RF power
     
    static let UHF_RF_POWER_MINUS_15_DB: Int = 0x0F
    
    /// UHF reader device -16dB RF power
     
    static let UHF_RF_POWER_MINUS_16_DB: Int = 0x10
    
    /// UHF reader device -17dB RF power
     
    static let UHF_RF_POWER_MINUS_17_DB: Int = 0x011
    
    /// UHF reader device -18dB RF power
     
    static let UHF_RF_POWER_MINUS_18_DB: Int = 0x012
    
    /// UHF reader device -19dB RF power
     
    static let UHF_RF_POWER_MINUS_19_DB: Int = 0x013
    
    /// UHF reader device automatic RF power management
     
    static let UHF_RF_POWER_AUTOMATIC_MODE: Int = 0x00
    
    /// UHF reader device fixed RF power with low bias
     
    static let UHF_RF_POWER_FIXED_LOW_BIAS_MODE: Int = 0x01
    
    /// UHF reader device fixed RF power with high bias
     
    static let UHF_RF_POWER_FIXED_HIGH_BIAS_MODE: Int = 0x02

    
    /// ISO15693 tag with no option bits
     
    static let ISO15693_OPTION_BITS_NONE: Int = 0x00
    
    /// ISO15693 tag with option bit for lock operations
     
    static let ISO15693_OPTION_BITS_LOCK: Int = 0x01
    
    /// ISO15693 tag with option bit for write operations
     
    static let ISO15693_OPTION_BITS_WRITE: Int = 0x02
    
    /// ISO15693 tag with option bit for read operations
    static let ISO15693_OPTION_BITS_READ: Int = 0x04
    
    /// ISO15693 tag with option bit for inventory operations
    static let ISO15693_OPTION_BITS_INVENTORY: Int = 0x08

    
    /// ISO15693 low bit-rate tag operations
    static let ISO15693_LOW_BITRATE: Int = 0
    
    /// ISO15693 high bit-rate tag operations
    static let ISO15693_HIGH_BITRATE: Int = 1

    
    /// UHF reader device RF carrier frequency from 902.75MHz to 927.5MHz
    /// (50 radio channels with frequency hopping)
    static let RF_CARRIER_FROM_902_75_TO_927_5_MHZ: Int = 0x00
    
    /// UHF reader device RF carrier frequency from 915.25MHz to 927.5MHz
    /// (25 radio channels with frequency hopping)
    static let RF_CARRIER_FROM_915_25_TO_927_5_MHZ: Int = 0x01
    
    /// UHF reader device RF carrier frequency 865.7MHz (no frequency hopping)
    static let RF_CARRIER_865_7_MHZ: Int = 0x02
    
    /// UHF reader device RF carrier frequency 866.3MHz (no frequency hopping)
     
    static let RF_CARRIER_866_3_MHZ: Int = 0x03
    
    /// UHF reader device RF carrier frequency 866.9MHz (no frequency hopping)
     
    static let RF_CARRIER_866_9_MHZ: Int = 0x04
    
    /// UHF reader device RF carrier frequency 867.5MHz (no frequency hopping)
     
    static let RF_CARRIER_867_5_MHZ: Int = 0x05
    
    /// UHF reader device RF carrier frequency from 865.7MHz to 867.5MHz
    /// (4 radio channels with frequency hopping)
     
    static let RF_CARRIER_FROM_865_7_TO_867_5_MHZ: Int = 0x06
    
    /// UHF reader device RF carrier frequency 915.1MHz (no frequency hopping)
     
    static let RF_CARRIER_915_1_MHZ: Int = 0x07
    
    /// UHF reader device RF carrier frequency 915.7MHz (no frequency hopping)
     
    static let RF_CARRIER_915_7_MHZ: Int = 0x08
    
    /// UHF reader device RF carrier frequency 916.3MHz (no frequency hopping)
     
    static let RF_CARRIER_916_3_MHZ: Int = 0x09
    
    /// UHF reader device RF carrier frequency 916.9MHz (no frequency hopping)
     
    static let RF_CARRIER_916_9_MHZ: Int = 0x0A
    
    /// UHF reader device RF carrier frequency from 915.1MHz to 916.9MHz
    /// (4 radio channels with frequency hopping)
     
    static let RF_CARRIER_FROM_915_1_TO_916_9_MHZ: Int = 0x0B
    
    /// UHF reader device RF carrier frequency 902.75MHz (no frequency hopping)
     
    static let RF_CARRIER_902_75_MHZ: Int = 0x0C
    
    /// UHF reader device RF carrier frequency 908.75MHz (no frequency hopping)
     
    static let RF_CARRIER_908_75_MHZ: Int = 0x0D
    
    /// UHF reader device RF carrier frequency 915.25MHz (no frequency hopping)
     
    static let RF_CARRIER_915_25_MHZ: Int = 0x0E
    
    /// UHF reader device RF carrier frequency 921.25MHz (no frequency hopping)
     
    static let RF_CARRIER_921_25_MHZ: Int = 0x0F
    
    /// UHF reader device RF carrier frequency 925.25MHz (no frequency hopping)
     
    static let RF_CARRIER_925_25_MHZ: Int = 0x10

    ///
    ///BLE security level 1 (no security).
    ///
    static let BLE_NO_SECURITY: Int = 0x00
    
    ///
    ///Legacy BLE security level 2.
    ///
    static let BLE_LEGACY_LEVEL_2_SECURITY: Int = 0x01
    
    ///
    /// LESC BLE security level 2.
    ///
    static let BLE_LESC_LEVEL_2_SECURITY: Int = 0x02
}
