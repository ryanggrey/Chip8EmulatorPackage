//
//  File.swift
//  
//
//  Created by Ryan Grey on 26/02/2021.
//

import Foundation

public protocol Chip8EngineDelegate {
    func render(screen: Chip8Screen)
    func beep()
}
