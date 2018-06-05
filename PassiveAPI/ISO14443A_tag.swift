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

public class ISO14443A_tag: Tag {
	/// Class Constructor
	///
    /// - parameter ID             - the tag ID
    /// - parameter passive_reader - reference to the passive reader object
	override init(ID: [UInt8], passiveReader: PassiveReader) {
        super.init(ID: ID, passiveReader: passiveReader)
    }
    
    override func toString() -> String {
        var tmp: String = ""
		
		if (reverseID) {
			for n in stride(from: ID.count, to: 0, by: -1) {
				tmp = tmp + PassiveReader.byteToHex(val: Int(ID[n]))
			}
		} else {
			for n in 0..<ID.count {
				tmp = tmp + PassiveReader.byteToHex(val: Int(ID[n]))
			}
		}
		
		return tmp
    }
}
