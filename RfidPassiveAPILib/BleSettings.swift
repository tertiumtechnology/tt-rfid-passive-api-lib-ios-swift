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

public class BleSettings
{
    //
    private let deviceManager = TxRxManager.getInstance()
    
    // TxRxManager singleton
    private static let _sharedInstance = BleSettings()
    
    /// Gets the singleton instance of the class
    ///
    /// NOTE: CLASS Method
    ///
    /// - returns: The singleton instance of TxRxManager class
    public class func getInstance() -> BleSettings {
        return _sharedInstance;
    }
    
    /// Returns the timeout value for the specified timeout event
    ///
    /// - parameter timeOutType: the timeout event
    /// - returns: the event timeout value, in MILLISECONDS
    public func getTimeOutValue(timeOutType: String) -> UInt32 {
        return deviceManager.getTimeOutValue(timeOutType: timeOutType)
    }
    
    /// Sets the current timeout value for the specified timeout event
    ///
    /// - parameter timeOutValue: the timeout value, in MILLISECONDS
    /// - parameter timeOutType: the timeout event
    public func setTimeOutValue(timeOutValue: UInt32, timeOutType: String) {
        return deviceManager.setTimeOutValue(timeOutValue: timeOutValue, timeOutType: timeOutType)
    }
    
    /// Resets timeout values to default values
    public func setTimeOutDefaults() {
        deviceManager.setTimeOutDefaults()
    }
}
