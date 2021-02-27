//
//  Chip8Engine.swift
//  
//
//  Created by Ryan Grey on 26/02/2021.
//

import Foundation

public class Chip8Engine: Chip8KeyHandler {
    private var timer: Timer?
    private let cpuHz: TimeInterval = 1/600
    private var chip8: Chip8!
    private let beepPlayer = BeepPlayer()
    public var delegate: Chip8EngineDelegate?

    public init() {
    }

    public func start(with rom: [Byte]) {
        stop()
        
        var chipState = ChipState()
        chipState.ram = rom

        self.chip8 = Chip8(
            state: chipState,
            cpuHz: cpuHz
        )

        timer = Timer.scheduledTimer(
            timeInterval: cpuHz,
            target: self,
            selector: #selector(self.timerFired),
            userInfo: nil,
            repeats: true
        )
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func timerFired() {
        chip8.cycle()
        guard let delegate = delegate else { return }
        if chip8.needsRedraw {
            delegate.render(screen: chip8.screen)
            chip8.needsRedraw = false
        }
        if chip8.shouldPlaySound {
            delegate.beep()
        }
    }

    public func handleKeyDown(key: Chip8InputCode) {
        chip8.handleKeyDown(key: key)
    }

    public func handleKeyUp(key: Chip8InputCode) {
        chip8.handleKeyUp(key: key)
    }
}
