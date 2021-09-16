//
//  AbstractZhagaListener.swift
//  RfidPassiveAPILib
//
//  Created by moouser on 16/08/21.
//  Copyright © 2021 Tertium. All rights reserved.
//

import Foundation

public class AbstractZhagaListener
{
    ///
    ///{@link ZhagaReader#setSecurityLevel(int) setSecurityLevel} command.
    ///
    public static let SET_SECURITY_LEVEL_COMMAND: Int = 28
    ///
    ///{@link ZhagaReader#getSecurityLevel() getSecurityLevel} command.
    ///
    public static let GET_SECURITY_LEVEL_COMMAND: Int = 29
    ///
    ///{@link ZhagaReader#setName(String) setName} command.
    ///
    public static let SET_DEVICE_NAME_COMMAND: Int = 30
    ///
    ///{@link ZhagaReader#getName() getName} command.
    ///
    public static let GET_DEVICE_NAME_COMMAND: Int = 31
    ///
    ///{@link ZhagaReader#reset(boolean) reset} command.
    ///
    public static let RESET_COMMAND: Int = 48
    ///
    ///{@link ZhagaReader#defaultBLEconfiguration(int, boolean) defaultBLEconfiguration} command.
    ///
    public static let DEFAULT_BLE_CONFIGURATION_COMMAND: Int = 49
    ///
    ///{@link ZhagaReader#getHMIsupport() getHMIsupport} command.
    ///
    public static let ZHAGA_GET_HMI_SUPPORT_COMMAND: Int = 50
    ///
    ///{@link ZhagaReader#setHMI(int, int, int, int, int, int, int, int, int, int, int) setHMI} command.
    ///
    public static let ZHAGA_SET_HMI_COMMAND: Int = 51
    ///
    ///{@link ZhagaReader#setRF(boolean) setRF} command.
    ///
    public static let ZHAGA_SET_RF_COMMAND: Int = 52
    ///
    ///{@link ZhagaReader#getRF() getRF} command.
    ///
    public static let ZHAGA_GET_RF_COMMAND: Int = 53
    ///
    ///{@link ZhagaReader#off() off} command.
    ///
    public static let ZHAGA_OFF_COMMAND: Int = 54
    ///
    ///{@link ZhagaReader#reboot() reboot} command.
    ///
    public static let ZHAGA_REBOOT_COMMAND: Int = 55
    ///
    ///{@link ZhagaReader#setSoundForInventory(int, int, int, int) setSoundForInventory} command.
    ///
    public static let ZHAGA_SET_INVENTORY_SOUND_COMMAND: Int = 56
    ///
    ///{@link ZhagaReader#getSoundForInventory() getSoundForInventory} command.
    ///
    public static let ZHAGA_GET_INVENTORY_SOUND_COMMAND: Int = 57
    ///
    ///{@link ZhagaReader#setSoundForCommand(int, int, int, int) setSoundForCommand} command.
    ///
    public static let ZHAGA_SET_COMMAND_SOUND_COMMAND: Int = 58
    ///
    ///{@link ZhagaReader#getSoundForCommand() getSoundForCommand} command.
    ///
    public static let ZHAGA_GET_COMMAND_SOUND_COMMAND: Int = 59
    ///
    ///{@link ZhagaReader#setSoundForError(int, int, int, int) setSoundForError} command.
    ///
    public static let ZHAGA_SET_ERROR_SOUND_COMMAND: Int = 60
    ///
    ///{@link ZhagaReader#getSoundForError() getSoundForError} command.
    ///
    public static let ZHAGA_GET_ERROR_SOUND_COMMAND: Int = 61
    ///
    ///{@link ZhagaReader#setLEDforInventory(int, int, int, int) setLEDforInventory} command.
    ///
    public static let ZHAGA_SET_INVENTORY_LED_COMMAND: Int = 62
    ///
    ///{@link ZhagaReader#getLEDforInventory() getLEDforInventory} command.
    ///
    public static let ZHAGA_GET_INVENTORY_LED_COMMAND: Int = 63
    ///
    ///{@link ZhagaReader#setLEDforCommand(int, int, int, int) setLEDforCommand} command.
    ///
    public static let ZHAGA_SET_COMMAND_LED_COMMAND: Int = 64
    ///
    ///{@link ZhagaReader#getLEDforCommand() getLEDforCommand} command.
    ///
    public static let ZHAGA_GET_COMMAND_LED_COMMAND: Int = 65
    ///
    ///{@link ZhagaReader#setLEDforError(int, int, int, int) setLEDforError} command.
    ///
    public static let ZHAGA_SET_ERROR_LED_COMMAND: Int = 66
    ///
    ///{@link ZhagaReader#getLEDforError() getLEDforError} command.
    ///
    public static let ZHAGA_GET_ERROR_LED_COMMAND: Int = 67
    ///
    ///{@link ZhagaReader#setVibrationForInventory(int, int, int) setVibrationForInventory} command.
    ///
    public static let ZHAGA_SET_INVENTORY_VIBRATION_COMMAND: Int = 68
    ///
    ///{@link ZhagaReader#getVibrationForInventory() getVibrationForInventory} command.
    ///
    public static let ZHAGA_GET_INVENTORY_VIBRATION_COMMAND: Int = 69
    ///
    ///{@link ZhagaReader#setVibrationForCommand(int, int, int) setVibrationForCommand} command.
    ///
    public static let ZHAGA_SET_COMMAND_VIBRATION_COMMAND: Int = 70
    ///
    ///{@link ZhagaReader#getVibrationForCommand() getVibrationForCommand} command.
    ///
    public static let ZHAGA_GET_COMMAND_VIBRATION_COMMAND: Int = 71
    ///
    ///{@link ZhagaReader#setVibrationForError(int, int, int) setVibrationForError} command.
    ///
    public static let ZHAGA_SET_ERROR_VIBRATION_COMMAND: Int = 72
    ///
    ///{@link ZhagaReader#getVibrationForError() getVibrationForError} command.
    ///
    public static let ZHAGA_GET_ERROR_VIBRATION_COMMAND: Int = 73
    ///
    ///{@link ZhagaReader#activateButton(int) activateButton} command.
    ///
    public static let ZHAGA_ACTIVATE_BUTTON_COMMAND: Int = 74
    ///
    ///{@link ZhagaReader#getActivatedButton() getActivatedButton} command.
    ///
    public static let ZHAGA_GET_ACTIVATED_BUTTON_COMMAND: Int = 75
    ///
    ///{@link ZhagaReader#setRFonOff(int, int, int) setRFonOff} command.
    ///
    public static let ZHAGA_SET_RF_ONOFF_COMMAND: Int = 76
    ///
    ///{@link ZhagaReader#getRFonOff() getRFonOff} command.
    ///
    public static let ZHAGA_GET_RF_ONOFF_COMMAND: Int = 77
    ///
    ///{@link ZhagaReader#setAutoOff(int) setAutoOff} command.
    ///
    public static let ZHAGA_SET_AUTOOFF_COMMAND: Int = 78
    ///
    ///{@link ZhagaReader#getAutoOff() getAutoOff} command.
    ///
    public static let ZHAGA_GET_AUTOOFF_COMMAND: Int = 79
    ///
    ///{@link ZhagaReader#defaultConfiguration() defaultConfiguration} command.
    ///
    public static let ZHAGA_DEFAULT_CONFIG_COMMAND: Int = 80
    ///
    ///{@link ZhagaReader#transparent(byte[]) transparent} command.
    ///
    public static let ZHAGA_TRANSPARENT_COMMAND: Int = 81


    ///
    ///Successful command code (no error).
    ///
    public static let NO_ERROR: Int = 0x00
    ///
    ///Invalid command parameter error code.
    ///
    public static let INVALID_PARAMETER_ERROR: Int = 0x0C
    ///
    ///Timeout error code.
    ///
    public static let TIMEOUT_ERROR: Int = 0x0D
    ///
    ///Not implemented command error code.
    ///
    public static let UNKNOWN_COMMAND_ERROR: Int = 0x0E
    ///
    ///Invalid command error code.
    ///
    public static let INVALID_COMMAND_ERROR: Int = 0x0F
    ///
    ///Reader write command failed error code.
    ///
    public static let READER_WRITE_FAIL_ERROR: Int = 0x10
    ///
    ///Reader write command timeout error code.
    ///
    public static let READER_WRITE_TIMEOUT_ERROR: Int = 0x11
    ///
    ///Reader read answer failed error code.
    ///
    public static let READER_READ_FAIL_ERROR: Int = 0x12
    ///
    ///Reader read answer timeout error code.
    ///
    public static let READER_READ_TIMEOUT_ERROR: Int = 0x13
    ///
    ///Reader command/answer mismatch error code.
    ///
    public static let READER_COMMAND_ANSWER_MISMATCH_ERROR: Int = 0x14
    ///
    ///Reader connection generic error.
    ///
    public static let READER_CONNECT_GENERIC_ERROR: Int = 0x15
    ///
    ///Reader connection timeout error.
    ///
    public static let READER_CONNECT_TIMEOUT_ERROR: Int = 0x16
    ///
    ///Reader connection error in discovering service.
    ///
    public static let READER_CONNECT_UNKNOW_SERVICE_ERROR: Int = 0x17
    ///
    ///Reader connection error: device not found.
    ///
    public static let READER_CONNECT_DEVICE_NOT_FOUND_ERROR: Int = 0x18
    ///
    ///Reader connection error: invalid BT adapter.
    ///
    public static let READER_CONNECT_INVALID_ADAPTER_ERROR: Int = 0x19
    ///
    ///Reader connection error: invalid device address.
    ///
    public static let READER_CONNECT_INVALID_DEVICE_ADDRESS_ERROR: Int = 0x1A
    ///
    ///Reader disconnection error: BLE not initialized.
    ///
    public static let READER_DISCONNECT_BLE_NOT_INITIALIZED_ERROR: Int = 0x1B
    ///
    ///Reader disconnection error: invalid BT adapter.
    ///
    public static let READER_DISCONNECT_INVALID_ADAPTER_ERROR: Int = 0x1C
    ///
    ///Reader read error: BLE device error.
    ///
    public static let READER_READ_BLE_DEVICE_ERROR: Int = 0x1D
    ///
    ///Reader read error: invalid TX characteristic.
    ///
    public static let READER_READ_INVALID_TX_CHARACTERISTIC_ERROR: Int = 0x1E
    ///
    ///Reader write error: BLE device error.
    ///
    public static let READER_WRITE_BLE_DEVICE_ERROR: Int = 0x1F
    ///
    ///Reader write error: invalid RX characteristic.
    ///
    public static let READER_WRITE_INVALID_RX_CHARACTERISTIC_ERROR: Int = 0x20
    ///
    ///Reader write error: previous operation in progress.
    ///
    public static let READER_WRITE_OPERATION_IN_PROGRESS_ERROR: Int = 0x21
    ///
    ///Reader driver not ready error.
    ///
    public static let READER_DRIVER_NOT_READY_ERROR: Int = 0x22
    ///
    ///Reader driver wrong status error.
    ///
    public static let READER_DRIVER_WRONG_STATUS_ERROR: Int = 0x23
    ///
    ///Reader driver unknow command error.
    ///
    public static let READER_DRIVER_UNKNOW_COMMAND_ERROR: Int = 0x24
    ///
    ///Reader driver command wrong parameter error.
    ///
    public static let READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR: Int = 0x25
    ///
    ///Reader driver command answer mismatch error.
    ///
    public static let READER_DRIVER_COMMAND_ANSWER_MISMATCH_ERROR: Int = 0x26
    ///
    ///Reader driver change-mode error.
    ///
    public static let READER_DRIVER_COMMAND_CHANGE_MODE_ERROR: Int = 0x27
    ///
    ///Reader command mode answer error.
    ///
    public static let READER_DRIVER_COMMAND_CMD_MODE_ANSWER_ERROR: Int = 0x28
    ///
    ///Reader set-mode error: BLE device error.
    ///
    public static let READER_SET_MODE_BLE_DEVICE_ERROR: Int = 0x29
    ///
    ///Reader set-mode error: invalid MODE characteristic.
    ///
    public static let READER_SET_MODE_INVALID_CHARACTERISTIC_ERROR: Int = 0x2A
    ///
    ///Reader set-mode error: previous operation in progress.
    ///
    public static let READER_SET_MODE_OPERATION_IN_PROGRESS_ERROR: Int = 0x2B
    ///
    /// Reader answer wrong format error code.
    ///
    public static let READER_ANSWER_WRONG_FORMAT_ERROR: Int = 0x2C
    ///
    ///BLE security level 1 (no security).
    ///
    public static let BLE_NO_SECURITY: Int = 0x00
    ///
    ///Legacy BLE security level 2.
    ///
    public static let BLE_LEGACY_LEVEL_2_SECURITY: Int = 0x01
    ///
    ///LESC BLE security level 2.
    ///
    public static let BLE_LESC_LEVEL_2_SECURITY: Int = 0x02

    ///
    ///Not reset BLE configuration.
    ///
    public static let BLE_CONFIGURATION_UNCHANGED: Int = 0x00
    ///
    ///Reset to default BLE configuration.
    ///
    public static let BLE_DEFAULT_CONFIGURATION: Int = 0x01
    ///
    ///Reset to default BLE configuration excluding device name.
    ///
    public static let BLE_DEFAULT_CONFIGURATION_EXCLUDING_NAME: Int = 0x02

    ///
    ///Reader device button #1
    ///
    public static let BUTTON_1: Int = 0x01
    ///
    ///Reader device button #2
    ///
    public static let BUTTON_2: Int = 0x02
    ///
    ///Reader device button #3
    ///
    public static let BUTTON_3: Int = 0x03
    ///
    ///Reader device button #4
    ///
    public static let BUTTON_4: Int = 0x04
    ///
    ///Reader device button #5
    ///
    public static let BUTTON_5: Int = 0x05
    ///
    ///Reader device button #6
    ///
    public static let BUTTON_6: Int = 0x06
    ///
    ///Reader device button #7
    ///
    public static let BUTTON_7: Int = 0x07
    ///
    ///Reader device button #8
    ///
    public static let BUTTON_8: Int = 0x08

    ///
    ///LED color RED
    ///
    public static let LED_RED: Int = 0x01
    ///
    ///LED color GREEN
    ///
    public static let LED_GREEN: Int = 0x02
    ///
    ///LED color BLUE
    ///
    public static let LED_BLUE: Int = 0x04
    ///
    ///LED color CYAN
    ///
    public static let LED_CYAN: Int = 0x08
    ///
    ///LED color MAGENTA
    ///
    public static let LED_MAGENTA: Int = 0x10
    ///
    ///LED color YELLOW
    ///
    public static let LED_YELLOW: Int = 0x20
    ///
    ///LED color WHITE
    ///
    public static let LED_WHITE: Int = 0x40

    ///
    ///Buzzer and vibration device NOT supported.
    ///
    public static let NO_BUZZER_NO_VIBRATION: Int = 0x00
    ///
    ///Buzzer supported and vibration device NOT supported.
    ///
    public static let BUZZER_BUT_NO_VIBRATION: Int = 0x01
    ///
    ///Buzzer NOT supported and vibration device supported.
    ///
    public static let NO_BUZZER_BUT_VIBRATION: Int = 0x02
    ///
    ///Buzzer and vibration device supported.
    ///
    public static let BUZZER_AND_VIBRATION: Int = 0x03

    ///
    ///Reader device activated button #1
    ///
    public static let ACTIVE_BUTTON_1: Int = 0x01
    ///
    ///Reader device activated button #2
    ///
    public static let ACTIVE_BUTTON_2: Int = 0x02
    ///
    ///Reader device activated button #3
    ///
    public static let ACTIVE_BUTTON_3: Int = 0x04
    ///
    ///Reader device activated button #4
    ///
    public static let ACTIVE_BUTTON_4: Int = 0x08
    ///
    ///Reader device activated button #5
    ///
    public static let ACTIVE_BUTTON_5: Int = 0x10
    ///
    ///Reader device activated button #6
    ///
    public static let ACTIVE_BUTTON_6: Int = 0x20
    ///
    ///Reader device activated button #7
    ///
    public static let ACTIVE_BUTTON_7: Int = 0x40
    ///
    ///Reader device activated button #8
    ///
    public static let ACTIVE_BUTTON_8: Int = 0x80
}
