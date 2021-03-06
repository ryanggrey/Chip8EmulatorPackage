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
    private var chip8: Chip8?
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
        
        resume()
    }
    
    private var isRunning: Bool {
        return timer != nil
    }
    
    private var isLoaded: Bool {
        return chip8 != nil
    }
    
    public func resume() {
        guard !isRunning && isLoaded else { return }

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
        guard let chip8 = chip8 else { return }
        
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
        guard let chip8 = chip8 else { return }

        chip8.handleKeyDown(key: key)
    }

    public func handleKeyUp(key: Chip8InputCode) {
        guard let chip8 = chip8 else { return }

        chip8.handleKeyUp(key: key)
    }
}
