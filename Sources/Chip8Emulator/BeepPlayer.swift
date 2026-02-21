//
//  File.swift
//
//
//  Created by Ryan Grey on 24/02/2021.
//

#if canImport(AVFoundation)
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
        let beepDataAsset = NSDataAsset(name: "beep", bundle: Bundle.module)!
        let beepData = beepDataAsset.data
        avPlayer = try! AVAudioPlayer(data: beepData)
    }

    public func play() {
        if !avPlayer.isPlaying {
            avPlayer.play()
        }
    }
}
#endif
