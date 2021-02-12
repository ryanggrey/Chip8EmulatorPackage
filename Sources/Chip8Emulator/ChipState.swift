//
//  ChipState.swift
//  CHIP-8
//
//  Created by Ryan Grey on 01/02/2021.
//

import Foundation

public struct ChipState {
    // 4K memory
    public var ram = [Byte](repeating: 0, count: 4096)
    // 16 variables
    public var v = [Byte](repeating: 0, count: 16)
    public var i: Word = 0
    // Roms loaded into 0x200. Memory prior to this is reserved (for font etc)
    public var pc: Word = 0x200
    public var screen = Chip8Screen()
    public var delayTimer: TimeInterval = 0
    public var soundTimer: TimeInterval = 0
    // 12 or 16 sized stack in real Chip-8, but allow this to grow dynamically
    public var stack = [Word]()
    // stack of currently pressed keys
    // last pressed key at top of stack
    // first pressed key on bottom of stak
    public var downKeys = NSMutableOrderedSet()

    public var isAwaitingKey = false
    public var needsRedraw = false

    public var shouldPlaySound: Bool {
        return soundTimer > 0
    }

    public var currentOp: Word {
        let byte1 = ram[pc]
        let byte2 = ram[pc + 1]
        let nibble1 = byte1 >> 4 // shift everything right by 4 bits, prefixing with 0s
        let nibble2 = byte1 & 0x0F // & with 00001111, causing the 1st nibble to be 0ed and the 2nd nibble to be preserved
        let nibble3 = byte2 >> 4
        let nibble4 = byte2 & 0x0F
        let opWord = Word(nibbles: [nibble1, nibble2, nibble3, nibble4])
        return opWord
    }
}
