//
//  AppDelegate.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 03.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let mediaPlayer: MediaPlayer = YandexMusicMediaPlayer()
    private let mediaController: MediaController = SerialPortMediaController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mediaPlayer.didUpdateUI = { [weak self] change in
            self?.mediaController.updateUI(change)
        }

        mediaController.didReceiveCommand = { [weak self] command in
            self?.mediaPlayer.handle(command: command)
        }
        mediaController.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        mediaController.stop()
    }
}
