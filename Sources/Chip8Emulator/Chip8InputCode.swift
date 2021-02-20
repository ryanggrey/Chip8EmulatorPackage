//
//  Chip8KeyCode.swift
//  CHIP-8
//
//  Created by Ryan Grey on 07/02/2021.
//

import Foundation

public enum Chip8InputCode: Int {
    case zero = 0x0
    case one = 0x1
    case two = 0x2 // up
    case three = 0x3
    case four = 0x4 // left
    case five = 0x5 // centre
    case six = 0x6 // right
    case seven = 0x7
    case eight = 0x8 // down
    case nine = 0x9
    case a = 0xa
    case b = 0xb
    case c = 0xc
    case d = 0xd
    case e = 0xe
    case f = 0xf
}
