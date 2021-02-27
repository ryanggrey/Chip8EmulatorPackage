//
//  ChipState.swift
//  CHIP-8
//
//  Created by Ryan Grey on 01/02/2021.
//

import Foundation

struct ChipState {
    init(
        // 4K memory
        ram: [Byte] = [Byte](repeating: 0, count: 4096),
        // 16 variables
        v: [Byte] = [Byte](repeating: 0, count: 16),
        i: Word = 0,
        // Roms loaded into 0x200. Memory prior to this is reserved (for font etc)
        pc: Word = 0x200,
        screen: Chip8Screen = Chip8Screen(),
        delayTimer: TimeInterval = 0,
        soundTimer: TimeInterval = 0,
        // 12 or 16 sized stack in real Chip-8, but allow this to grow dynamically
        stack: [Word] = [Word](),
        downKeys: NSMutableOrderedSet = NSMutableOrderedSet(),
        isAwaitingKey: Bool = false,
        needsRedraw: Bool = false) {
        self.ram = ram
        self.v = v
        self.i = i
        self.pc = pc
        self.screen = screen
        self.delayTimer = delayTimer
        self.soundTimer = soundTimer
        self.stack = stack
        self.downKeys = downKeys
        self.isAwaitingKey = isAwaitingKey
        self.needsRedraw = needsRedraw
    }
    
    var ram: [Byte]
    var v: [Byte]
    var i: Word
    var pc: Word
    var screen: Chip8Screen
    var delayTimer: TimeInterval
    var soundTimer: TimeInterval
    var stack = [Word]()
    // stack of currently pressed keys
    // last pressed key at top of stack
    // first pressed key on bottom of stak
    var downKeys: NSMutableOrderedSet
    var isAwaitingKey: Bool
    var needsRedraw: Bool
    
    var shouldPlaySound: Bool {
        return soundTimer > 0
    }
    
    var currentOp: Word {
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
