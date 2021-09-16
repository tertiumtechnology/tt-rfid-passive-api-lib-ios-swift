//
//  AbstractZhagaListenerProtocol.swift
//  RfidPassiveAPILib
//
//  Created by moouser on 16/08/21.
//  Copyright © 2021 Tertium. All rights reserved.
//

import Foundation

///
/// Listener template for event generated in response to a {@code ZhagaReader}
/// method invocation.
///
/// A concrete instance of {@code AbstractZhagaListener} has to set for the
/// instance of the class {@code PassiveReader} to receive notification about
/// methods invocation.
///
public protocol AbstractZhagaListenerProtocol {
    /// Invoked after a {@link PassiveReader#connect(String, android.content.Context)} method invocation
    /// to notify failure.
    ///
    /// @param error error code
    func connectionFailedEvent(error: Int)

    ///
    /// Invoked after a {@link ZhagaReader#connect(String)} method invocation
    /// to notify success.
    ///
    func connectionSuccessEvent()

    ///
    /// Invoked after a {@link ZhagaReader#disconnect()} method invocation
    /// to notify success.
    ///
    func disconnectionSuccessEvent()

    ///
    /// Invoked after a class {@code ZhagaReader} method invocation to notify
    /// result.
    ///
    /// @param command  the command sent to the reader
    /// @param error  the error code
    ///
    func resultEvent(command: Int, error: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getSecurityLevel() getSecurityLevel}
    /// method invocation to notify result.
    ///
    /// @param level  the current security level
    ///
    func securityLevelEvent(level: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getName() getName}
    /// method invocation to notify result.
    ///
    /// @param device_name  the reader name
    ///
    func nameEvent(device_name: String)

    ///
    /// Invoked asynchronously to detail a reader device button event.
    ///
    /// @param button  the reader device button pressed (1-8)
    /// @param time  the time that the button has been pressed (ms)
    ///
    func buttonEvent(button: Int, time: Int)

    ///
    /// Invoked asynchronously to signal a reader device event.
    ///
    /// @param event_number  the sequence number of reader device event
    /// @param event_code  the reader device event feature code
    ///
    func deviceEventEvent(event_number: Int, event_code: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getHMIsupport() getHMIsupport}
    /// method invocation to notify result.
    ///
    /// @param LED_color   the color(s) supported by reader device LED
    /// @param sound_vibration   the sound and/or vibration capabilities of reader device
    /// @param button_number   the number of button(s) of the reader device
    ///
    func HMIevent(LED_color: Int, sound_vibration: Int, button_number: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getSoundForInventory() getSoundForInventory}
    /// method invocation to notify result.
    ///
    /// @param sound_frequency   sound frequency (40-20000 Hz)
    /// @param sound_on_time   duration of sound (0-2550 ms)
    /// @param sound_off_time   duration of sound interval (0-2550 ms)
    /// @param sound_repetition   number of repetition (0-255, 0 = NO suond)
    ///
    func soundForInventoryEvent(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getSoundForCommand() getSoundForCommand}
    /// method invocation to notify result.
    ///
    /// @param sound_frequency   sound frequency (40-20000 Hz)
    /// @param sound_on_time   duration of sound (0-2550 ms)
    /// @param sound_off_time   duration of sound interval (0-2550 ms)
    /// @param sound_repetition   number of repetition (0-255, 0 = NO suond)
    ///
    func soundForCommandEvent(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getSoundForError() getSoundForError}
    /// method invocation to notify result.
    ///
    /// @param sound_frequency   sound frequency (40-20000 Hz)
    /// @param sound_on_time   duration of sound (0-2550 ms)
    /// @param sound_off_time   duration of sound interval (0-2550 ms)
    /// @param sound_repetition   number of repetition (0-255, 0 = NO suond)
    ///
    func soundForErrorEvent(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getLEDforInventory() getLEDforInventory}
    /// method invocation to notify result.
    ///
    /// @param light_color   LED color
    /// @param light_on_time   duration of light (0-2550 ms)
    /// @param light_off_time   duration of light interval (0-2550 ms)
    /// @param light_repetition   number of repetition (0-255, 0 = NO light)
    ///
    func LEDforInventoryEvent(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getLEDforCommand() getLEDforCommand}
    /// method invocation to notify result.
    ///
    /// @param light_color   LED color
    /// @param light_on_time   duration of light (0-2550 ms)
    /// @param light_off_time   duration of light interval (0-2550 ms)
    /// @param light_repetition   number of repetition (0-255, 0 = NO light)
    ///
    func LEDforCommandEvent(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getLEDforError() getLEDforError}
    /// method invocation to notify result.
    ///
    /// @param light_color   LED color
    /// @param light_on_time   duration of light (0-2550 ms)
    /// @param light_off_time   duration of light interval (0-2550 ms)
    /// @param light_repetition   number of repetition (0-255, 0 = NO light)
    ///
    func LEDforErrorEvent(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getVibrationForInventory() getVibrationForInventory}
    /// method invocation to notify result.
    ///
    /// @param vibration_on_time   duration of vibration (0-2550 ms)
    /// @param vibration_off_time   duration of vibration interval (0-2550 ms)
    /// @param vibration_repetition   number of repetition (0-255, 0 = NO vibration)
    ///
    func vibrationForInventoryEvent(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getVibrationForCommand() getVibrationForCommand}
    /// method invocation to notify result.
    ///
    /// @param vibration_on_time   duration of vibration (0-2550 ms)
    /// @param vibration_off_time   duration of vibration interval (0-2550 ms)
    /// @param vibration_repetition   number of repetition (0-255, 0 = NO vibration)
    ///
    func vibrationForCommandEvent(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getVibrationForError() getVibrationForError}
    /// method invocation to notify result.
    ///
    /// @param vibration_on_time   duration of vibration (0-2550 ms)
    /// @param vibration_off_time   duration of vibration interval (0-2550 ms)
    /// @param vibration_repetition   number of repetition (0-255, 0 = NO vibration)
    ///
    func vibrationForErrorEvent(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getActivatedButton() getActivatedButton}
    /// method invocation to notify result.
    ///
    /// @param activated_button   activated button(s)
    ///
    func activatedButtonEvent(activated_button: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getRFonOff() getRFonOff}
    /// method invocation to notify result.
    ///
    /// @param RF_power   RF power (0-100 %)
    /// @param RF_off_timeout   timeout to switch off RF (0-65535 ms)
    /// @param RF_on_preactivation   time of RF preactivation (0-65535 ms)
    ///
    func RFonOffEvent(RF_power: Int, RF_off_timeout: Int, RF_on_preactivation: Int)

    ///
    /// Invoked after a {@link ZhagaReader#getAutoOff() getAutoOff}
    /// method invocation to notify result.
    ///
    /// @param OFF_time   auto-OFF time (0-65535 s)
    ///
    func autoOffEvent(OFF_time: Int)

    ///
    /// Invoked after a {@link ZhagaReader#transparent(byte[]) transparent}
    /// method invocation to notify result.
    ///
    /// @param answer  the answer received from the tag
    ///
    func transparentEvent(answer: [UInt8]?)
    
    ///
    /// Invoked after a {@link ZhagaReader#getRF() getRF}
    /// method invocation to notify result.
    ///
    /// @param RF_on RF permanently set ON
    ///
    func RFevent(RF_on: Bool)
}
