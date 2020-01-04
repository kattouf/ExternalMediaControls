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
}

final class YandexMusicMediaController: MediaController {

    // MARK: - MediaControls
    func prev() {
        executeAppleScript(named: ScriptsName.prev)
    }

    func play() {
        executeAppleScript(named: ScriptsName.play)
    }

    func next() {
        executeAppleScript(named: ScriptsName.next)
    }

    // MARK: - Private methods
    private func executeAppleScript(named: String) {
        guard let scriptURL = Bundle.main.url(forResource: named, withExtension: "scpt"),
            let script = NSAppleScript(contentsOf: scriptURL, error: nil) else {
                return
        }

        script.executeAndReturnError(nil)
    }
}
