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
}

final class YandexMusicMediaController: MediaController {

    // MARK: - MediaController
    func handle(command: MediaCommand) {
        let scriptName: String
        
        switch command {
        case .prev:
            scriptName = ScriptsName.prev
        case .play:
            scriptName = ScriptsName.play
        case .next:
            scriptName = ScriptsName.next
        case .volumeUp:
            scriptName = ScriptsName.volumeUp
        case .volumeDown:
            scriptName = ScriptsName.volumeDown
        }

        executeAppleScript(named: scriptName)
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
