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

    @IBOutlet weak var window: NSWindow!

    private let mediaController: MediaController = YandexMusicMediaController()
    private let mediaCommandsObserver: MediaCommandsObserver = SerialPortMediaCommandsObserver()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mediaCommandsObserver.didReceiveCommand = { [weak self] command in
            switch command {
            case .prev:
                self?.mediaController.prev()
            case .play:
                self?.mediaController.play()
            case .next:
                self?.mediaController.next()
            }
        }
        mediaCommandsObserver.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        mediaCommandsObserver.stop()
    }
}
