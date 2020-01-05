//
//  YandexMusicMediaController.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 04.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Foundation

private struct ScriptsName {
    static let prev = "yamusic_prev"
    static let play = "yamusic_play_pause"
    static let next = "yamusic_next"
    static let volumeUp = "yamusic_vol_up"
    static let volumeDown = "yamusic_vol_down"
    static let volumeChange = "yamusic_vol_change"
    static let like = "yamusic_like_unlike"
}

final class YandexMusicMediaController: MediaController {
    // MARK: - Private properties
    private let volumeChangeThrottler = Throttler(minimumDelay: 0.05)

    // MARK: - MediaController
    func handle(command: MediaCommand) {
        switch command {
        case .prev:
            AppleScriptRunner.executeScript(named: ScriptsName.prev)
        case .play:
            AppleScriptRunner.executeScript(named: ScriptsName.play)
        case .next:
            AppleScriptRunner.executeScript(named: ScriptsName.next)
        case .volumeUp:
            AppleScriptRunner.executeScript(named: ScriptsName.volumeUp)
        case .volumeDown:
            AppleScriptRunner.executeScript(named: ScriptsName.volumeDown)
        case .like:
            AppleScriptRunner.executeScript(named: ScriptsName.like)
        case .volume(let value):
            volumeChangeThrottler.throttle {
                AppleScriptRunner.executeMethodFromScript(named: ScriptsName.volumeChange,
                                                          methodName: "setVolume",
                                                          withParameters: [String(value)])
            }
        }
    }
}
