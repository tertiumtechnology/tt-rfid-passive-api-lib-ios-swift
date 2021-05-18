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

/// Listener template for event generated in response to a {@code PassiveReader}
/// method invocation.
///
/// A concrete instance of {@code AbstractReaderListenerProtocol} has to set for the
/// instance of the class {@code PassiveReader} to receive notification about
/// methods invocation.
public protocol AbstractReaderListenerProtocol {
    /// Invoked after a {@link PassiveReader#connect(String, android.content.Context)} method invocation
    /// to notify failure.
    /// 
    /// @param error error code
    func connectionFailureEvent(error: Int)
	
    /// Invoked after a {@link PassiveReader#connect(String, android.content.Context)} method invocation
    /// to notify success.
    func connectionSuccessEvent()
	
    /// Invoked after a {@link PassiveReader#disconnect()} method invocation
    /// to notify success.
    func disconnectionEvent()
    
    /// Invoked after a {@link PassiveReader#testAvailability() testAvailibility}
    /// method invocation to notify result.
    /// @param available  if true the reader is linked by BLE to the device
    func availabilityEvent(available: Bool)
	
    /// Invoked after a class {@code PassiveReader} method invocation to notify
    /// result.
    /// @param command  the command sent to the reader
    /// @param error  the error code
    func resultEvent(command: Int, error: Int)
	
    /// Invoked after a {@link PassiveReader#getBatteryStatus() getBatteryStatus}
    /// method invocation to notify result.
    /// @param status  the battery status
    func batteryStatusEvent(status: Int)
	
    /// Invoked after a {@link PassiveReader#getFirmwareVersion()
    /// getFirmwareVersion} method invocation to notify result.
    /// @param major  the firmware version major number
    /// @param minor  the firmware version minor number
    func firmwareVersionEvent(major: Int, minor: Int)
	
    /// Invoked after a {@link PassiveReader#getShutdownTime() getShutdownTime}
    /// method invocation to notify result.
    /// @param time  the shutdown time (seconds)
    func shutdownTimeEvent(time: Int)
	
    /// Invoked after a {@link PassiveReader#getRFpower() getRFpower} method
    /// invocation to notify result.
    /// @param level  the RF power level
    /// @param mode  the RF power mode
    func RFpowerEvent(level: Int, mode: Int)
	
    /// Invoked after a {@link PassiveReader#getBatteryLevel() getBatteryLevel}
    /// method invocation to notify result.
    /// @param level  the battery charge level (volt)
    func batteryLevelEvent(level: Float)
	
    /// Invoked after a {@link PassiveReader#getRFforISO15693tunnel() 
    /// getRFforISO15693tunnel} method invocation to notify result.
    /// @param delay  the delay from RF power switch-on and command transmission
    /// (milliseconds)
    /// @param timeout  the time before RF power switch-off (seconds)
    func RFforISO15693tunnelEvent(delay: Int, timeout: Int)
	
    /// Invoked after a {@link PassiveReader#getISO15693optionBits() 
    /// getISO15693optionBits} method invocation to notify result.
    /// @param option_bits  the option bits
    func ISO15693optionBitsEvent(option_bits: Int)
	
    /// Invoked after a {@link PassiveReader#getISO15693extensionFlag() 
    /// getISO15693extensionFlag} method invocation to notify result.
    /// @param flag  if true the extension flag is configured
    /// @param permanent  if true the extension flag is permanent configured
    func ISO15693extensionFlagEvent(flag: Bool, permanent: Bool)
	
    /// Invoked after a {@link PassiveReader#getISO15693bitrate() 
    /// getISO15693bitrate} method invocation to notify result.
    /// @param bitrate  the bit-rate configured
    /// @param permanent  if true the bit-rate is permanent configured
    func ISO15693bitrateEvent(bitrate: Int, permanent: Bool)
    
    /// Invoked after a {@link PassiveReader#getEPCfrequency() getEPCfrequency}
    /// method invocation to notify result.
    /// @param frequency  the RF frequency
    func EPCfrequencyEvent(frequency: Int)
	
    /// Invoked after a {@link PassiveReader#ISO15693tunnel(byte[]) ISO15693tunnel}
    /// or {@link PassiveReader#ISO15693encryptedTunnel(byte, byte[])
    /// ISO15693encryptedTunnel} method invocation to notify result.
    /// @param data  command answer data
    func tunnelEvent(data: [UInt8]?)
    
    ///
    ///I nvoked after a {@link PassiveReader#getSecurityLevel() getSecurityLevel}
    /// method invocation to notify result.
    ///
    /// @param level  the current security level
    ///
    func securityLevelEvent(level: Int)
}
