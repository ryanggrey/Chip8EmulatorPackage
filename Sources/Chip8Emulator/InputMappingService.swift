//
//  InputMappingService.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation

public protocol InputMappingService {
    associatedtype InputType: Hashable
    associatedtype OutputType
    func mapping(for romName: RomName) -> Dictionary<InputType, OutputType>?
}
