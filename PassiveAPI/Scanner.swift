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

/// Performs the scanning of Tertium Ble Devices
public class Scanner: TxRxDeviceScanProtocol {
    class Timeouts {
        static let S_TERTIUM_TIMEOUT_CONNECT = TxRxManagerTimeouts.S_TERTIUM_TIMEOUT_CONNECT
        static let S_TERITUM_TIMEOUT_RECEIVE_FIRST_PACKET = TxRxManagerTimeouts.S_TERITUM_TIMEOUT_RECEIVE_FIRST_PACKET
        static let S_TERTIUM_TIMEOUT_RECEIVE_PACKETS = TxRxManagerTimeouts.S_TERTIUM_TIMEOUT_RECEIVE_PACKETS
        static let S_TERTIUM_TIMEOUT_SEND_PACKET = TxRxManagerTimeouts.S_TERTIUM_TIMEOUT_SEND_PACKET
    }
    
    /// Scanner singleton
    private static let instance: Scanner = Scanner()
    
    /// Class delegate
    var delegate: AbstractScanListenerProtocol? = nil

    /// TxRxManager instance
    private let deviceManager: TxRxManager = TxRxManager.getInstance()
    
    /// Gets Scanner class singleton instance
    static func getInstance() -> Scanner {
        return Scanner.instance
    }
    
    init() {
        deviceManager._delegate = self
    }
    
    /// Commences the scanning of devices
    func startScan() {
        deviceManager.startScan()
    }
    
    /// Returns wether device scanning began
    ///
    /// - returns - bool indicating if the scanning of devices began
    func isScanning() -> Bool {
        return deviceManager._isScanning
    }
    
    /// Stops device scanning
    func stopScan() {
        deviceManager.stopScan()
    }
    
    /// Returns an instance of TxRxDevice from device's name
    ///
    /// - parameter device: the device name
    /// - returns: the device instance, if found, otherwise nil
    func deviceFromDeviceName(name: String) -> TxRxDevice? {
        return deviceManager.deviceFromDeviceName(name: name)
    }
    
    /// Returns the device name from an instance of TxRxDevice
    ///
    /// - parameter device: the device instance
    /// - returns: the device name
    func getDeviceName(device: TxRxDevice) -> String {
        return deviceManager.getDeviceName(device: device)
    }
    
    // APACHE CORDOVA UTILITY METHODS
    
    /// Returns an instance of TxRxDevice from device's indexed name
    ///
    /// - parameter device: the device indexed name
    /// - returns: the device instance, if found, otherwise nil
    func deviceFromIndexedName(name: String) -> TxRxDevice? {
        return deviceManager.deviceFromIndexedName(name: name)
    }
    
    /// Returns an instance of TxRxDevice from device's indexed name
    ///
    /// - parameter device: the device to get indexed name from
    /// - returns: the device instance, if found, otherwise nil
    func getDeviceIndexedName(device: TxRxDevice) -> String {
        return deviceManager.getDeviceIndexedName(device: device)
    }
    
    // TxRxDeviceScanProtocol implementation
    public func deviceScanBegan() {
        delegate?.deviceScanBeganEvent()
    }
    
    public func deviceFound(device: TxRxDevice) {
        delegate?.deviceFoundEvent(deviceName: device.name)
    }
    
    public func deviceScanEnded() {
        delegate?.deviceScanEndedEvent()
    }
    
    public func deviceScanError(error: NSError) {
        if error.code == TxRxManagerErrors.ErrorCodes.ERROR_BLUETOOTH_NOT_READY_OR_LOST.rawValue {
            delegate?.deviceScanErrorEvent(error: AbstractScanListener.READER_DISCONNECT_BLE_NOT_INITIALIZED_ERROR)
            return
        }

        delegate?.deviceScanErrorEvent(error: AbstractScanListener.READER_DISCONNECT_BLE_NOT_INITIALIZED_ERROR)
    }
    
    public func deviceInternalError(error: NSError) {
        // TODO: Handle?
        delegate?.deviceScanErrorEvent(error: AbstractScanListener.READER_DISCONNECT_BLE_NOT_INITIALIZED_ERROR)
    }
}
