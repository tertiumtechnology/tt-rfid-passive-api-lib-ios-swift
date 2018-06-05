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

/// Listener template for event generated in response to a Tag method
/// invocation.
///

/// A concrete instance of AbstractResponseListener has to set for every
/// class Tag object instance to receive notification about methods
/// invocation.
public protocol AbstractResponseListenerProtocol {

    /// Invoked after a EPC_tag#writeID(byte[], short) writeID method
    /// invocation to notify result.
    /// - parameter error - the error code
    func writeIDevent(tagID: [UInt8]?, error: Int)
    
    /// Invoked after a EPC_tag#writeKillPassword(byte[], byte[])
    /// writeKillPassword or EPC_tag#writeAccessPassword(byte[], byte[])
    /// writeAccessPassword method invocation to notify result.
    /// - parameter error - the error code
    func writePasswordEvent(tagID: [UInt8]?, error: Int)
    
    /// Invoked after a EPC_tag#readTID(int, byte[]) readTID method invocation
    /// to notify result.
    /// - parameter error - the error code
    /// - parameter TID - the tag ID
    func readTIDevent(tagID: [UInt8]?, error: Int, TID: [UInt8]?)
    
    /// Invoked after a EPC_tag#read(int, int, byte[]) read or
    /// ISO15693_tag#read(int, int) read method invocation to notify
    /// result.
    /// - parameter error - the error code
    /// - parmeter data - the data read
    func readEvent(tagID: [UInt8]?, error: Int, data: [UInt8]?)
    
    /// Invoked after a EPC_tag#write(int, byte[], byte[]) write or
    /// ISO15693_tag#write(int, byte[]) write method invocation to notify
    /// result.
    /// - parameter error - the error code
    func writeEvent(tagID: [UInt8]?, error: Int)
    
    /// Invoked after a EPC_tag#lock(int, byte[]) lock or {@link
    /// ISO15693_tag#lock(int, int) lock method invocation to notify result.
    /// - parameter error - the error code
    func lockEvent(tagID: [UInt8]?, error: Int)
    
    /// Invoked after a EPC_tag#kill(byte[]) kill method invocation to
    /// notify result.
    /// - parameter error - the error code
    func killEvent(tagID: [UInt8]?, error: Int)
}
