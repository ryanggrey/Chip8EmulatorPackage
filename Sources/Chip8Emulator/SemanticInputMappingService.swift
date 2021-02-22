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
        .blinky : [
            .up : .three,
            .down : .six,
            .left : .seven,
            .right : .eight
        ],
        .breakout : [
            .left : .four,
            .right : .six
        ],
        .cave : [
            .primaryAction : .f,
            .up : .two,
            .down : .eight,
            .left : .four,
            .right : .six
        ],
        .filter : [
            .left : .four,
            .right : .six
        ],
        .kaleidoscope : [
            .primaryAction : .f,
            .up : .two,
            .down : .eight,
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
        .spaceFlight : [
            .primaryAction : .f,
            .secondaryAction : .e,
            .up : .one,
            .down : .four
        ],
        .spaceIntercept : [
            .primaryAction : .one,
            .secondaryAction : .two,
            .left : .four,
            .up : .five,
            .right : .six
        ],
        .spaceInvaders : [
            .primaryAction : .five,
            .left : .four,
            .right : .six
        ],
        .squash : [
            .up : .one,
            .down : .four
        ],
        .tank : [
            .primaryAction : .five,
            .left : .four,
            .right : .six,
            .down : .two,
            .up : .eight
        ],
        .tapeWorm : [
            .primaryAction : .f,
            .left : .four,
            .right : .six,
            .up : .two,
            .down : .eight
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
        ],
        .worm : [
            .primaryAction : .five,
            .left : .four,
            .right : .six,
            .up : .two,
            .down : .eight
        ],
        .xMirror : [
            .primaryAction : .f,
            .up : .two,
            .down : .eight,
            .left : .four,
            .right : .six
        ]
    ]

    public func chip8InputCode(from romName: RomName, from input: SemanticInputCode) -> Chip8InputCode? {
        return semanticMapping[romName]?[input]
    }
}
