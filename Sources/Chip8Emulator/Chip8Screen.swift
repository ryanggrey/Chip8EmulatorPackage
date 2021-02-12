//
//  Chip8Screen.swift
//  CHIP-8
//
//  Created by Ryan Grey on 06/02/2021.
//

import Foundation

public struct Chip8Screen {
    public init(pixels: [Byte] = [Byte](repeating: 0, count: Chip8Screen.width * Chip8Screen.height)) {
        self.pixels = pixels
    }

    public static let width = 64
    public static let height = 32
    public let size = Size(width: Chip8Screen.width, height: Chip8Screen.height)
    var pixels: [Byte]
}
