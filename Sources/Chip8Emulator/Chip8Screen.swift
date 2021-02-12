//
//  Chip8Screen.swift
//  CHIP-8
//
//  Created by Ryan Grey on 06/02/2021.
//

import Foundation

struct Chip8Screen {
    private static let width = 64
    private static let height = 32
    let size = Size(width: Chip8Screen.width, height: Chip8Screen.height)
    var pixels = [Byte](repeating: 0, count: Chip8Screen.width * Chip8Screen.height)
}
