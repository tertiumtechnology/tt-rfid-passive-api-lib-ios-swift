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

public class Tag {
    private static let DEFAULT_TIMEOUT: Int = 2000
    internal let ID: [UInt8]
    var reverseID: Bool
    var timeout: Int
    internal let passiveReader: PassiveReader
    
    /// Class constructor
    ///
    /// - parameter ID - the tag ID
    /// - parameter passiveReader - the passive reader instance which handles the tag
    init(ID: [UInt8], passiveReader: PassiveReader) {
        self.ID = ID
        reverseID = false
        timeout = Tag.DEFAULT_TIMEOUT
        self.passiveReader = passiveReader
    }
    
    func toString() -> String {
        return ""
    }
    
    /// Get Tag ID
    ///
    /// if the reverse ID flag is set to true return tag ID with bytes in reverse order
	///
    /// - parameter reverseID - if reverse the tag ID
    /// - returns - the tag id
    func setReverseID(reverseID: Bool) {
        self.reverseID = reverseID
    }
    
    /// Get the tag ID
    ///
    /// - returns - the tag id
    func getID() -> [UInt8] {
        return ID
    }
    
    /// Set the timeout value for every tag related command
    ///
    /// - parameter timeout - The timeout in milliseconds
    func setTimeout(timeout: Int) {
        self.timeout = timeout
    }
    
    /// Get the timeout value
    ///
    /// - returns - the timeout value in milliseconds
    func getTimeout() -> Int {
        return timeout
    }
}
