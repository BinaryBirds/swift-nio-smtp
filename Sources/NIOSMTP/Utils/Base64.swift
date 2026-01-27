//
//  Base64.swift
//  NIOSMTP
//
//  Created by Binary Birds on 2026. 01. 26..
//

//  Foundation-free Base64 encoding for byte arrays.
extension Array where Element == UInt8 {
    /// Returns a Base64 string representation of the byte array.
    func base64EncodedString() -> String {
        guard !isEmpty else {
            return ""
        }

        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".utf8)
        var output: [UInt8] = []
        output.reserveCapacity(((count + 2) / 3) * 4)

        var index = 0
        while index < count {
            let byte0 = self[index]
            let byte1 = (index + 1 < count) ? self[index + 1] : 0
            let byte2 = (index + 2 < count) ? self[index + 2] : 0

            let triple = (UInt32(byte0) << 16) | (UInt32(byte1) << 8) | UInt32(byte2)

            output.append(alphabet[Int((triple >> 18) & 0x3F)])
            output.append(alphabet[Int((triple >> 12) & 0x3F)])

            if index + 1 < count {
                output.append(alphabet[Int((triple >> 6) & 0x3F)])
            } else {
                output.append(UInt8(ascii: "="))
            }

            if index + 2 < count {
                output.append(alphabet[Int(triple & 0x3F)])
            } else {
                output.append(UInt8(ascii: "="))
            }

            index += 3
        }

        return String(decoding: output, as: UTF8.self)
    }
}
