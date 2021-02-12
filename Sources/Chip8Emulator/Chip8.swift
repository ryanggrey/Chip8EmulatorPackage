//
//  Chip8.swift
//  CHIP-8
//
//  Created by Ryan Grey on 22/01/2021.
//

import Foundation

struct NotImplemented: Error {}

public class Chip8 {
    private var state: ChipState
    private let opExecutor: OpExecutor

    public init(
        state: ChipState,
        cpuHz: TimeInterval
    ) {
        self.state = state
        self.opExecutor = OpExecutor(cpuHz: cpuHz)
    }

    public var needsRedraw: Bool {
        get {
            return state.needsRedraw
        }
        set {
            state.needsRedraw = newValue
        }
    }

    public var shouldPlaySound: Bool {
        return state.shouldPlaySound
    }

    public var screen: Chip8Screen {
        return state.screen
    }

    public func cycle() {
        self.state = try! opExecutor.handle(state: self.state, op: state.currentOp)
    }

    public func handleKeyDown(key: Int) {
        state.downKeys.add(Byte(key))
    }

    public func handleKeyUp(key: Int) {
        state.downKeys.remove(Byte(key))
    }
}
