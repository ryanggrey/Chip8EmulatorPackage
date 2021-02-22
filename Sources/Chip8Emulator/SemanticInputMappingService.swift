//
//  SemanticInputMapping.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation

public struct SemanticInputMappingService {
    private let semanticMapping: [RomName : [SemanticInputCode : Chip8InputCode]] = [
        .airplane : [
            .primaryAction : .eight
        ],
        .astroDodge : [
            .primaryAction : .five,
            .left : .four,
            .right : .six
        ],
        .breakout : [
            .left : .four,
            .right : .six
        ],
        .filter : [
            .left : .four,
            .right : .six
        ],
        .landing : [
            .primaryAction : .eight
        ],
        .lunarLander : [
            .primaryAction : .two,
            .left : .four,
            .right : .six
        ],
        .missile : [
            .primaryAction : .eight
        ],
        .pong : [
            .up : .one,
            .down : .four
        ],
        .rocket : [
            .primaryAction : .f
        ],
        .spaceInvaders : [
            .primaryAction : .five,
            .left : .four,
            .right : .six
        ],
        .tetris : [
            .secondaryAction : .seven,
            .primaryAction : .four,
            .left : .five,
            .right : .six
        ],
        .wipeOff : [
            .left : .four,
            .right : .six
        ]
    ]

    public func chip8InputCode(from romName: RomName, from input: SemanticInputCode) -> Chip8InputCode? {
        return semanticMapping[romName]?[input]
    }
}
