//
//  File.swift
//  
//
//  Created by Ryan Grey on 24/02/2021.
//

import Foundation
import AVFoundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

public struct BeepPlayer {
    private let avPlayer: AVAudioPlayer

    public init() {
        let resourceName = "beep"

        #if os(macOS)

        // for some reason macOS cannot load the NSDataAsset (returns nil) so must find url
        let beepUrl = Bundle.emulator.url(forResource: resourceName, withExtension: "wav")!
        avPlayer = try! AVAudioPlayer(contentsOf: beepUrl)

        #else

        // all other platforms function correctly with NSDataAsset
        // but some do not function correctly loading the url (tvOS returns nil)
        let beepDataAsset = NSDataAsset(name: resourceName, bundle: Bundle.emulator)!
        let beepData = beepDataAsset.data
        avPlayer = try! AVAudioPlayer(data: beepData)

        #endif
    }

    public func play() {
        if !avPlayer.isPlaying {
            avPlayer.play()
        }
    }
}
