//
// The MIT License
//
// Copyright 2021 Tertium Technology.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

///
/// Interface for instance(s) of {@code PassiveReader} limited to Zhaga standard protocol.
///
/// A concrete instance of {@code ZhagaReader} is created calling
/// {@link PassiveReader#getZhagaReaderInstance(AbstractZhagaListener)
/// getZhagaReaderInstance} static method..
///
public protocol ZhagaReaderProtocol {    
    ///
    /// Connect the reader device via BLE link.
    ///
    /// - parameter -  reader_address:  the reader device address
    ///
    func connect(reader_address: String)
    
    ///
    /// Disconnect the BLE link with reader device.
    ///
    func disconnect()
    
    ///
    /// Close the reader driver.
    ///
    func close()
    
    ///
    /// Test the BLE link with reader device.
    ///
    /// - parameter  device_address:  the sound starting frequency (Hertz: 40-20000)
    /// - returns: true if the reader device is linked by BLE
    ///
    func isAvailable(device_address: String) -> Bool
    
    ///
    /// Set the reader device security level.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} or via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    /// The new security level will be set after a power off/on cycle of the
    /// reader device.
    ///
    /// - parameter level: the new security level
    ///
    func setSecurityLevel(level: Int)
    
    ///
    /// Get the reader device security level.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#securityLevelEvent(int) securityLevelEvent} or via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#securityLevelEvent(int) securityLevelEvent} methods
    /// invocation.
    ///
    func getSecurityLevel()
    
    ///
    /// Set the reader device name.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} or via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// The new configuration will be active after a reader device reset or power off/on cycle
    ///
    /// - parameter device_name:  the reader name
    ///
    func setName(device_name: String)
    
    ///
    /// Get the reader device name.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractReaderListener#nameEvent(String) nameEvent} or via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#nameEvent(String) nameEvent}methods
    /// invocation.
    ///
    func getName()
    
    ///
    /// Reset the reader device.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} or via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter bootloader: enter FUOTA (Firmware Update On The Air) mode
    ///
    func reset(bootloader: Bool)
    
     ///
    /// Reset the reader device to BLE factory default configuration.
    ///
    /// Response to the command received via {@link
    /// AbstractReaderListener#resultEvent(int, int) resultEvent} or via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// The new configuration will be active after a reader device reset or power off/on cycle
    ///
    /// - parameter mode:  reset BLE configuration mode (0: reset none, 1: reset all, 2: reset all except device name)
    /// - parameter erase_bonding: erase bonding list of BLE devices
    ///
    func defaultBLEconfiguration(mode: Int, erase_bonding: Bool)
    
    ///
    /// Get Human-Machine Interface supported features of the reader device.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#HMIevent(int, int, int) HMIevent} methods
    /// invocation.
    ///
    func getHMIsupport()
    
    ///
    /// Control Human-Machine Interface of the reader device.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter sound_frequency:  sound frequency (40-20000 Hz)
    /// - parameter sound_on_time:   duration of sound (0-2550 ms)
    /// - parameter sound_off_time:   duration of sound interval (0-2550 ms)
    /// - parameter sound_repetition:   number of repetition (0-255, 0: Int = NO suond)
    /// - parameter light_color:   LED color
    /// - parameter light_on_time:   duration of light (0-2550 ms)
    /// - parameter light_off_time:   duration of light interval (0-2550 ms)
    /// - parameter light_repetition:   number of repetition (0-255, 0: Int = NO light)
    /// - parameter vibration_on_time:   duration of vibration (0-2550 ms)
    /// - parameter vibration_off_time:   duration of vibration interval (0-2550 ms)
    /// - parameter vibration_repetition:   number of repetition (0-255, 0: Int = NO vibration)
    ///
    func setHMI(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int,
                       light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int,
                       vibration_on_time: Int, vibration_off_time: Int, int vibration_repetition: Int)
    ///
    /// Set the RF permanently ON or under automatic control by reader device.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameters RF_on: set RF permanently ON
    ///
    func setRF(RF_on: Bool)
    
    ///
    /// Get the RF settings for reader device.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#RFevent(boolean) RFvent}
    /// methods invocation.
    ///
    func getRF()
    
    ///
    /// Power-off the reader device.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    func off()
    
    ///
    /// Reboot the reader device.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    func reboot()
    
    ///
    /// Setup sound parameters for successfull inventory operation.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter sound_frequency:   sound frequency (40-20000 Hz)
    /// - parameter sound_on_time:   duration of sound (0-2550 ms)
    /// - parameter sound_off_time:  duration of sound interval (0-2550 ms)
    /// - parameter sound_repetition:  number of repetition (0-255, 0: Int = NO suond)
    ///
    func setSoundForInventory(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int)
    
    ///
    /// Get sound parameters for successfull inventory operation.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#soundForInventoryEvent(int, int, int, int) soundForInventoryEvent}
    /// methods invocation.
    ///
    func getSoundForInventory()
    
    ///
    /// Setup sound parameters for successfull general command.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter sound_frequency:   sound frequency (40-20000 Hz)
    /// - parameter sound_on_time:  duration of sound (0-2550 ms)
    /// - parameter sound_off_time:   duration of sound interval (0-2550 ms)
    /// - parameter sound_repetition:   number of repetition (0-255, 0: Int = NO suond)
    ///
    func setSoundForCommand(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int)
    
    ///
    /// Get sound parameters for successfull general command.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#soundForCommandEvent(int, int, int, int) soundForCommandEvent}
    /// methods invocation.
    ///
    func getSoundForCommand()
    
    ///
    /// Setup sound parameters for error condition.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter sound_frequency:   sound frequency (40-20000 Hz)
    /// - parameter sound_on_time:   duration of sound (0-2550 ms)
    /// - parameter sound_off_time:   duration of sound interval (0-2550 ms)
    /// - parameter sound_repetition:   number of repetition (0-255, 0: Int = NO suond)
    ///
    func setSoundForError(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int)
    
    ///
    /// Get sound parameters for error condition.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#soundForErrorEvent(int, int, int, int) soundForErrorEvent}
    /// methods invocation.
    ///
    func getSoundForError()
    
    ///
    /// Setup LED parameters for successfull inventory operation.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter light_color:   LED color
    /// - parameter light_on_time:   duration of light (0-2550 ms)
    /// - parameter light_off_time:   duration of light interval (0-2550 ms)
    /// - parameter light_repetition:   number of repetition (0-255, 0: Int = NO light)
    ///
    func setLEDforInventory(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int)
    
    ///
    /// Get LED parameters for successfull inventory operation.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#LEDforInventoryEvent(int, int, int, int) LEDforInventoryEvent}
    /// methods invocation.
    ///
    func getLEDforInventory()
    
    ///
    /// Setup LED parameters for successfull general command.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter light_color:   LED color
    /// - parameter light_on_time:   duration of light (0-2550 ms)
    /// - parameter light_off_time:   duration of light interval (0-2550 ms)
    /// - parameter light_repetition:   number of repetition (0-255, 0: Int = NO light)
    ///
    func setLEDforCommand(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int)
    
    ///
    /// Get LED parameters for successfull general command.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#LEDforCommandEvent(int, int, int, int) LEDforCommandEvent}
    /// methods invocation.
    ///
    func getLEDforCommand()
    
    ///
    /// Setup LED parameters for error condition.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter - light_color   LED color
    /// - parameter - light_on_time   duration of light (0-2550 ms)
    /// - parameter - light_off_time   duration of light interval (0-2550 ms)
    /// - parameter - light_repetition   number of repetition (0-255, 0: Int = NO light)
    ///
    func setLEDforError(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int)
    
    ///
    /// Get LED parameters for error condition.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#LEDforErrorEvent(int, int, int, int) LEDforErrorEvent}
    /// methods invocation.
    ///
    func getLEDforError()
    
    ///
    /// Setup vibration parameters for successfull inventory operation.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter vibration_on_time:   duration of vibration (0-2550 ms)
    /// - parameter vibration_off_time:   duration of vibration interval (0-2550 ms)
    /// - parameter vibration_repetition:   number of repetition (0-255, 0: Int = NO vibration)
    ///
    func setVibrationForInventory(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int)
    
    ///
    /// Get vibration parameters for successfull inventory operation.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#vibrationForInventoryEvent(int, int, int) vibrationForInventoryEvent}
    /// methods invocation.
    ///
    func getVibrationForInventory()
    
    ///
    /// Setup vibration parameters for successfull general command.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter vibration_on_time:  duration of vibration (0-2550 ms)
    /// - parameter vibration_off_time:   duration of vibration interval (0-2550 ms)
    /// - parameter vibration_repetition:   number of repetition (0-255, 0: Int = NO vibration)
    ///
    func setVibrationForCommand(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int)
    
    ///
    /// Get vibration parameters for successfull general command.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#vibrationForCommandEvent(int, int, int) vibrationForCommandEvent}
    /// methods invocation.
    ///
    func getVibrationForCommand()
    
    ///
    /// Setup vibration parameters for error condition.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter vibration_on_time:   duration of vibration (0-2550 ms)
    /// - parameter vibration_off_time:  duration of vibration interval (0-2550 ms)
    /// - parameter vibration_repetition:   number of repetition (0-255, 0: Int = NO vibration)
    ///
    func setVibrationForError(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int)
    
    ///
    /// Get vibration parameters for error condition.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#vibrationForErrorEvent(int, int, int) vibrationForErrorEvent}
    /// methods invocation.
    ///
    func getVibrationForError()
    
    ///
    /// Reader device button(s) activation.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// Only activated buttons generate events
    ///
    /// - parameter activated_button:   button(s) to activate
    ///
    func activateButton(activated_button: Int)
    
    ///
    /// Get reader device activated button(s).
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#activatedButtonEvent(int) activatedButtonEvent}
    /// methods invocation.
    ///
    /// Only activated buttons generate events
    ///
    func getActivatedButton()
    
    ///
    /// Setup RF on/off settings.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter RF_power:   RF power (0-100 %)
    /// - parameter RF_off_timeout:   timeout to switch off RF (0-65535 ms)
    /// - parameter RF_on_preactivation:   time of RF preactivation (0-65535 ms)
    ///
    func setRFonOff(RF_power: Int, RF_off_timeout: Int, RF_on_preactivation: Int)
    
    ///
    /// Get RF on/off settings.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#RFonOffEvent(int, int, int) RFonOffEvent}
    /// methods invocation.
    ///
    func getRFonOff()
    
    ///
    /// Setup reader device auto-OFF.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} method invocation.
    ///
    /// - parameter OFF_time:   auto-OFF time (0-65535 s)
    ///
    func setAutoOff(OFF_time: Int)
    
    ///
    /// Get reader device auto-OFF time.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent} and {@link
    /// AbstractZhagaListener#autoOffEvent(int) autoOffEvent}
    /// methods invocation.
    ///
    func getAutoOff()
    
    ///
    /// Reset to default configuratin.
    ///
    /// Response to the command received via {@link
    /// AbstractZhagaListener#resultEvent(int, int) resultEvent}
    /// method invocation.
    ///
    func defaultConfiguration()
    
    ///
    /// Start Zhaga transparent operation.
    ///
    /// In transparent operation the command bytes are in stripped ISO15693 format.
    ///
    /// The result of the transparent operation is notified invoking Zhaga listener
    /// method {@link AbstractZhagaListener#transparentEvent(byte[]) transparentEvent}.
    ///
    /// - parameter command:  the command to send to the tag
    ///
    func transparent(command: [UInt8])
}
