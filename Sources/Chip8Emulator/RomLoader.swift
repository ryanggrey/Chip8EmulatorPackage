//
//  RomLoader.swift
//  CHIP-8
//
//  Created by Ryan Grey on 23/01/2021.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

public struct RomLoader {
    public static func loadRam(from romName: RomName) -> [Byte] {
        guard let romData = NSDataAsset(name: romName.rawValue, bundle: Bundle.emulator)?.data else {
            print("Rom not found: " + romName.rawValue)
            return []
        }
        let rom = [Byte](romData)
        let ram = RomLoader.loadRam(from: rom)
        return ram
    }

    public static func read(romPath path: String) -> [Byte] {
        guard FileManager.default.fileExists(atPath: path) else {
            print("Rom not found: " + path)
            return []
        }

        do {
            let url = URL(fileURLWithPath: path)
            let romData = try Data(contentsOf: url)
            let rom = [Byte](romData)
            return loadRam(from: rom)
        } catch {
            // contents could not be loaded
            print("Rom not found: " + path)
            return []
        }
    }

    private static func loadRam(from rom: [Byte]) -> [Byte] {
        var ram = [Byte](repeating: 0, count: 4096)

        let font = Font.bytes
        ram.replaceSubrange(0..<font.count, with: font)

        ram.replaceSubrange(0x200..<0x200+rom.count, with: rom)

        return ram
    }
}
