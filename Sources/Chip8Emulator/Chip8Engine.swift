//
//  Chip8Engine.swift
//
//
//  Created by Ryan Grey on 26/02/2021.
//

import Foundation

public class Chip8Engine: Chip8KeyHandler {
    #if canImport(ObjectiveC)
    private var timer: Timer?
    #endif
    private let cpuHz: TimeInterval = 1/600
    private var chip8: Chip8?
    #if canImport(AVFoundation)
    private let beepPlayer = BeepPlayer()
    #endif
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

    private var isLoaded: Bool {
        return chip8 != nil
    }

    #if canImport(ObjectiveC)
    private var isRunning: Bool {
        return timer != nil
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
        tick()
    }
    #else
    public func resume() {
        // On non-ObjC platforms (e.g. WASM), the caller drives the loop via tick()
    }

    public func stop() {
        // On non-ObjC platforms, the caller manages the loop
    }
    #endif

    public func tick() {
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
