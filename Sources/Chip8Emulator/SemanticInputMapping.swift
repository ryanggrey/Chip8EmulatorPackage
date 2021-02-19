//
//  SemanticInputMapping.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation

public typealias SemanticInputMapping = [SemanticInputCode : Chip8KeyCode]

extension SemanticInputMapping {
    static let airplane: SemanticInputMapping = [
        .primaryAction : .eight
    ]

    static let astroDodge: SemanticInputMapping = [
        .primaryAction : .five,
        .left : .four,
        .right : .six
    ]

    static let breakout: SemanticInputMapping = [
        .left : .four,
        .right : .six
    ]

    static let filter: SemanticInputMapping = Self.breakout

    static let landing: SemanticInputMapping = [
        .primaryAction : .eight
    ]

    static let lunarLanding: SemanticInputMapping = [
        .primaryAction : .two,
        .left : .four,
        .right : .six
    ]

    static let missile: SemanticInputMapping = [
        .primaryAction : .eight
    ]

    static let none: SemanticInputMapping = [:]

    static let pong: SemanticInputMapping = [
        .up : .four,
        .down : .one
    ]

    static let rocket: SemanticInputMapping = [
        .primaryAction : .f
    ]

    static let spaceInvaders: SemanticInputMapping = [
        .primaryAction : .five,
        .left : .four,
        .right : .six
    ]

    static let tetris: SemanticInputMapping = [
        .secondaryAction : .seven,
        .primaryAction : .four,
        .left : .five,
        .right : .six
    ]

    static let wipeOff: SemanticInputMapping = breakout
}
