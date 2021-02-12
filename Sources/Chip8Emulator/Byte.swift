//
//  Byte.swift
//  CHIP-8
//
//  Created by Ryan Grey on 26/01/2021.
//

import Foundation

public typealias Byte = UInt8 // 8 bits

extension Byte {
    init(nibbles: [Byte]) {
        self = nibbles.reduce(0x0) { (last, next) -> Byte in
            return last << 4 | Byte(next)
        }
    }
}

extension Array {
    subscript(place: Byte) -> Element {
        get {
            return self[Int(place)]
        }
        set {
            self[Int(place)] = newValue
        }
    }
}
