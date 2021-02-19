//
//  InputMappingService.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation
import Chip8Emulator

public protocol InputMappingService {
    associatedtype Mapping
    func mapping(for romName: RomName) -> Mapping?
}
