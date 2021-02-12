//
//  Size.swift
//  CHIP-8
//
//  Created by Ryan Grey on 06/02/2021.
//

import Foundation

public struct Size {
    public let width: Int
    public let height: Int
    public var area: Int {
        return width * height
    }
}
