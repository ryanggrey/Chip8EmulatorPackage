//
//  Word.swift
//  CHIP-8
//
//  Created by Ryan Grey on 25/01/2021.
//

import Foundation

public typealias Word = UInt16 // 16 bits

extension Word {
    init(nibbles: [Byte]) {
        self = nibbles.reduce(0x0) { (last, next) -> Word in
            return last << 4 | Word(next)
        }
    }

    init(bytes: [Byte]) {
        self = bytes.reduce(0x0) { (last, next) -> Word in
            return last << 8 | Word(next)
        }
    }

    var byte1: Byte {
        // shift everything right by 8 bits, prefixing with 0s
        return Byte(self >> 8)
    }

    var byte2: Byte {
        // & with 0000000011111111, causing the 1st byte to be 0ed and the 2nd byte to be preserved
        return Byte(self & 0b0000000011111111)
    }

    var nibble1: Byte {
        // shift everything right by 4 bits, prefixing with 0s
        return byte1 >> 4
    }

    var nibble2: Byte {
        // & with 00001111, causing the 1st nibble to be 0ed and the 2nd nibble to be preserved
        return byte1 & 0b00001111
    }

    var nibble3: Byte {
        // shift everything right by 4 bits, prefixing with 0s
        return byte2 >> 4
    }

    var nibble4: Byte {
        // & with 00001111, causing the 1st nibble to be 0ed and the 2nd nibble to be preserved
        return byte2 & 0b00001111
    }
}

extension Array {
    subscript(place: Word) -> Element {
        get {
            return self[Int(place)]
        }
        set {
            self[Int(place)] = newValue
        }
    }
}
