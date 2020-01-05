//
//  YandexMusicMediaPlayer.swift
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
    static let likeStatus = "yamusic_like_status"
}

final class YandexMusicMediaPlayer: MediaPlayer {
    // MARK: - Private properties
    private let volumeChangeThrottler = Throttler(minimumDelay: 0.05)
    private var timer: Timer?

    // MARK: - MediaController
    var didChangeUIState: ((MediaUIState) -> Void)? {
        didSet {
            if didChangeUIState != nil {
                startStateUpdateTimer()
            } else {
                stopStateUpdateTimer()
            }
        }
    }

    func handle(command: MediaCommand) {
        switch command {
        case .prev:
            AppleScriptRunner.executeScript(named: ScriptsName.prev)
            updateLikeAfterChangeTrackScript()
        case .play:
            AppleScriptRunner.executeScript(named: ScriptsName.play)
        case .next:
            AppleScriptRunner.executeScript(named: ScriptsName.next)
            updateLikeAfterChangeTrackScript()
        case .volumeUp:
            AppleScriptRunner.executeScript(named: ScriptsName.volumeUp)
        case .volumeDown:
            AppleScriptRunner.executeScript(named: ScriptsName.volumeDown)
        case .like:
            AppleScriptRunner.executeScript(named: ScriptsName.like)
            updateLikeAfterChangeTrackScript()
        case .volume(let value):
            volumeChangeThrottler.throttle {
                AppleScriptRunner.executeMethodFromScript(named: ScriptsName.volumeChange,
                                                          methodName: "setVolume",
                                                          withParameters: [String(value)])
            }
        }
    }

    // MARK: - Private methods
    private func startStateUpdateTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.updateLikeState()
        }
        timer?.fire()
    }

    private func stopStateUpdateTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateLikeAfterChangeTrackScript() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateLikeState()
        }
    }

    private func updateLikeState() {
        if let result = AppleScriptRunner.executeMethodFromScript(named: ScriptsName.likeStatus,
                                                                  methodName: "getLiked"),
            let isLiked = Bool(result) {
            didChangeUIState?(.liked(isLiked))
        }
    }
}
