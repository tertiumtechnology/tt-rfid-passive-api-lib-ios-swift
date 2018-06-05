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

public class AbstractResponseListener {
    /// {@link EPC_tag#read(int, int, byte[]) read} or
    /// {@link ISO15693_tag#read(int, int) read} command.
    static let READ_COMMAND: Int = 100
    
    /// {@link EPC_tag#write(int, byte[], byte[]) write} or
    /// {@link ISO15693_tag#write(int, byte[]) write} command.     
    static let WRITE_COMMAND: Int = 101
    
    /// {@link EPC_tag#lock(int, byte[]) lock} or
    /// {@link ISO15693_tag#lock(int, int) lock command.    
    static let LOCK_COMMAND: Int = 102
    
    /// {@link EPC_tag#writeID(byte[], short) writeID} command.  
    static let WRITEID_COMMAND: Int = 103
    
    /// {@link EPC_tag#kill(byte[]) kill} command.    
    static let KILL_COMMAND: Int = 104
    
    /// {@link EPC_tag#readTID(int, byte[]) readTID} command.
    static let READ_TID_COMMAND: Int = 105
    
    /// {@link EPC_tag#writeKillPassword(byte[], byte[]) writeKillPassword} command.   
    static let WRITEKILLPASSWORD_COMMAND: Int = 106
    
    /// {@link EPC_tag#writeAccessPassword(byte[], byte[]) writeAccessPassword} command.   
    static let WRITEACCESSPASSWORD_COMMAND: Int = 107

    
    /// Successful tag operation (no error).
    static let NO_ERROR: Int = 0x00
    
    /// Tag operation with memory error.     
    static let MEMORY_ERROR: Int = 0x01
    
    /// Tag operation with locked memory error.     
    static let MEMORY_LOCKED: Int = 0x02
    
    /// Tag operation with invalid parameter error.    
    static let PARAMETER_INVALID: Int = 0x0C
    
    /// Timeout error for tag operation.     
    static let TIMEOUT_ERROR: Int = 0x0D
    
    /// Wrong command in tag operation.    
    static let WRONG_COMMAND: Int = 0x0E
    
    /// Invalid command in tag operation.
    static let INVALID_COMMAND: Int = 0x0F
    
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
    
    /// Reader driver not ready error     
    static let READER_DRIVER_NOT_READY_ERROR: Int = 0x22
    
    /// Reader driver wrong status error.     
    static let READER_DRIVER_WRONG_STATUS_ERROR: Int = 0x23
    
    /// Reader driver un-know command error.
    static let READER_DRIVER_UNKNOW_COMMAND_ERROR: Int = 0x24
    
    /// Reader driver command wrong parameter error.
    static let READER_DRIVER_COMMAND_WRONG_PARAMETER_ERROR: Int = 0x25
}
