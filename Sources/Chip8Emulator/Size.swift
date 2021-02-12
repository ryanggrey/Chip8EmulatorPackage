//
//  Size.swift
//  CHIP-8
//
//  Created by Ryan Grey on 06/02/2021.
//

import Foundation

struct Size {
    let width: Int
    let height: Int
    var area: Int {
        return width * height
    }
}
