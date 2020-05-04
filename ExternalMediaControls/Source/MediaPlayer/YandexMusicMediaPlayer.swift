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
    static let playStatus = "yamusic_play_status"
    static let likeStatus = "yamusic_like_status"
    static let trackInfo = "yamusic_track_info"
}

final class YandexMusicMediaPlayer: MediaPlayer {
    // MARK: - Private properties
    private let volumeChangeThrottler = Throttler(minimumDelay: 0.05)
    private var timer: Timer?

    // MARK: - MediaController
    var didUpdateUI: ((MediaUIChange) -> Void)? {
        didSet {
            if didUpdateUI != nil {
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
                updateUIWithDelay {
                    self.updateTrackInfo()
                    self.updateLikeStatus()
                }
            case .play:
                AppleScriptRunner.executeScript(named: ScriptsName.play)
                updateUIWithDelay(updates: updatePlayStatus)
            case .next:
                AppleScriptRunner.executeScript(named: ScriptsName.next)
                updateUIWithDelay {
                    self.updateTrackInfo()
                    self.updateLikeStatus()
                }
            case .volumeUp:
                AppleScriptRunner.executeScript(named: ScriptsName.volumeUp)
            case .volumeDown:
                AppleScriptRunner.executeScript(named: ScriptsName.volumeDown)
            case .like:
                AppleScriptRunner.executeScript(named: ScriptsName.like)
                updateUIWithDelay(updates: updateLikeStatus)
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
            self?.updatePlayStatus()
            self?.updateTrackInfo()
            self?.updateLikeStatus()
        }
        timer?.fire()
    }

    private func stopStateUpdateTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateUIWithDelay(updates: @escaping () -> Void) {
        // workaround: waits for change track
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: updates)
    }

    private func updatePlayStatus() {
        guard let result = AppleScriptRunner.executeMethodFromScript(named: ScriptsName.playStatus,
                                                                     methodName: "getPlayStatus"),
            let value = Bool(result) else {
                return
        }

        didUpdateUI?(.isPlaying(value))
    }

    private func updateLikeStatus() {
        guard let result = AppleScriptRunner.executeMethodFromScript(named: ScriptsName.likeStatus,
                                                                     methodName: "getLiked"),
            let value = Bool(result) else {
                return
        }

        didUpdateUI?(.isLiked(value))
    }

    private func updateTrackInfo() {
        guard let result = AppleScriptRunner.executeMethodFromScript(named: ScriptsName.trackInfo,
                                                                     methodName: "getTrackInfo") else {
                return
        }

        let rows = result.split(separator: "\n")
        guard rows.count == 2 else {
            return
        }

        didUpdateUI?(.trackInfo(title: String(rows[0]), artist: String(rows[1])))
    }
}
