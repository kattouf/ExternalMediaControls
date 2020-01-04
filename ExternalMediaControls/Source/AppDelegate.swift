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

    private let mediaController: MediaController = YandexMusicMediaController()
    private let mediaCommandsObserver: MediaCommandsObserver = SerialPortMediaCommandsObserver()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mediaCommandsObserver.didReceiveCommand = { [weak self] command in
            self?.mediaController.handle(command: command)
        }
        mediaCommandsObserver.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        mediaCommandsObserver.stop()
    }
}
