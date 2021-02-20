//
//  InputMappingService.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation

public protocol PlatformInputMappingService {
    associatedtype PlatformInputCode
    
    func semanticInputCode(from romName: RomName, from platformInputCode: PlatformInputCode) -> SemanticInputCode?
}
