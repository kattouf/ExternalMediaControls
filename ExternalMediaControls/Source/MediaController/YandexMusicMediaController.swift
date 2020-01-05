//
//  YandexMusicMediaController.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 04.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Foundation
import Carbon

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
            executeAppleScript(named: ScriptsName.prev)
        case .play:
            executeAppleScript(named: ScriptsName.play)
        case .next:
            executeAppleScript(named: ScriptsName.next)
        case .volumeUp:
            executeAppleScript(named: ScriptsName.volumeUp)
        case .volumeDown:
            executeAppleScript(named: ScriptsName.volumeDown)
        case .like:
            executeAppleScript(named: ScriptsName.like)
        case .volume(let value):
            volumeChangeThrottler.throttle {
                self.executeMethodsFromAppleScript(named: ScriptsName.volumeChange,
                                                   methodName: "setVolume",
                                                   withParameter: String(value))
            }
        }
    }

    // MARK: - Private methods
    private func executeAppleScript(named: String) {
        guard let scriptURL = Bundle.main.url(forResource: named, withExtension: "scpt"),
            let script = NSAppleScript(contentsOf: scriptURL, error: nil) else {
                return
        }

        script.executeAndReturnError(nil)
    }

    func executeMethodsFromAppleScript(named: String,
                                       methodName: String,
                                       withParameter parameter: String) {
        guard let scriptURL = Bundle.main.url(forResource: named, withExtension: "scpt"),
            let script = NSAppleScript(contentsOf: scriptURL, error: nil) else {
                return
        }

        let message = NSAppleEventDescriptor(string: parameter)

        let parameters = NSAppleEventDescriptor(listDescriptor: ())
        parameters.insert(message, at: 1)

        var psn = ProcessSerialNumber(highLongOfPSN: UInt32(0), lowLongOfPSN: UInt32(kCurrentProcess))

        let target = NSAppleEventDescriptor(descriptorType: typeProcessSerialNumber,
                                            bytes: &psn,
                                            length: MemoryLayout<ProcessSerialNumber>.size)

        let handler = NSAppleEventDescriptor(string: methodName)

        let event = NSAppleEventDescriptor.appleEvent(withEventClass: AEEventClass(kASAppleScriptSuite),
                                                      eventID: AEEventID(kASSubroutineEvent),
                                                      targetDescriptor: target,
                                                      returnID: AEReturnID(kAutoGenerateReturnID),
                                                      transactionID: AETransactionID(kAnyTransactionID))

        event.setParam(handler, forKeyword: AEKeyword(keyASSubroutineName))
        event.setParam(parameters, forKeyword: AEKeyword(keyDirectObject))

        script.executeAppleEvent(event, error: nil)
    }
}
