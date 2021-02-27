//
//  File 2.swift
//  
//
//  Created by Ryan Grey on 26/02/2021.
//

import Foundation

protocol Chip8KeyHandler {
    func handleKeyDown(key: Chip8InputCode)
    func handleKeyUp(key: Chip8InputCode)
}
