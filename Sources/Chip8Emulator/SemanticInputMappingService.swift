//
//  RomSemanticInput.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation

public struct SemanticInputMappingService: InputMappingService {
    private let mapping: [RomName : SemanticInputMapping] = [
        .chip8 : .none,
        .airplane : .airplane,
        .astroDodge: .astroDodge,
        .breakout: .breakout,
        .filter : .filter,
        .landing : .landing,
        .lunarLander : .lunarLanding,
        .maze : .none,
        .missile : .missile,
        .pong : .pong,
        .rocket : .rocket,
        .spaceInvaders : .spaceInvaders,
        .tetris : .tetris,
        .wipeOff : .wipeOff
    ]

    public init() {}

    public func mapping(for romName: RomName) -> SemanticInputMapping? {
        return mapping[romName]
    }
}
