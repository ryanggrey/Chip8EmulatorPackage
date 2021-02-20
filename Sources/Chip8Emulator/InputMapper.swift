//
//  InputMapper.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation

public struct InputMapper<PlatformInputMappingServiceType: PlatformInputMappingService> {
    private let platformInputMappingService: PlatformInputMappingServiceType
    private let semanticInputMappingService = SemanticInputMappingService()

    public init(platformInputMappingService: PlatformInputMappingServiceType) {
        self.platformInputMappingService = platformInputMappingService
    }

    public func map(
        platformInput: PlatformInputMappingServiceType.PlatformInputCode,
        romName: RomName
        ) -> Chip8InputCode? {
        guard let semanticInputCode = platformInputMappingService.semanticInputCode(from: romName, from: platformInput),
              let chip8KeyCode =  semanticInputMappingService.chip8InputCode(from: romName, from: semanticInputCode)
        else { return nil }

        return chip8KeyCode
    }
}
