//
//  Chip8.swift
//  CHIP-8
//
//  Created by Ryan Grey on 22/01/2021.
//

import Foundation

struct NotImplemented: Error {}

class Chip8: Chip8KeyHandler {
    private var state: ChipState
    private let opExecutor: OpExecutor

    init(
        state: ChipState,
        cpuHz: TimeInterval
    ) {
        self.state = state
        self.opExecutor = OpExecutor(cpuHz: cpuHz)
    }

    var needsRedraw: Bool {
        get {
            return state.needsRedraw
        }
        set {
            state.needsRedraw = newValue
        }
    }

    var shouldPlaySound: Bool {
        return state.shouldPlaySound
    }

    var screen: Chip8Screen {
        return state.screen
    }

    func cycle() {
        self.state = try! opExecutor.handle(state: self.state, op: state.currentOp)
    }

    func handleKeyDown(key: Chip8InputCode) {
        state.downKeys.add(Byte(key.rawValue))
    }

    func handleKeyUp(key: Chip8InputCode) {
        state.downKeys.remove(Byte(key.rawValue))
    }
}
