//
//  AppDelegate.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 03.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Cocoa
import ORSSerial

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    private var port: ORSSerialPort?
    private let mediaControls: MediaControls = YandexMusicMediaControls()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let port = ORSSerialPort(path: "/dev/cu.usbmodem144101") else {
            print("cannot connect to port")
            return
        }
        port.baudRate = 9600
        port.parity = .none
        port.numberOfStopBits = 1
        port.usesRTSCTSFlowControl = true
        port.delegate = self
        port.open()

        self.port = port
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        self.port?.close()
    }
}

// MARK: - ORSSerialPortDelegate
extension AppDelegate: ORSSerialPortDelegate {
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print(#function)
    }

    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        let receivedString = String(data: data, encoding: .utf8)

        switch receivedString {
        case "4":
            mediaControls.prev()
        case "2":
            mediaControls.play()
        case "1":
            mediaControls.next()
        default:
            break
        }
    }

    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        print(#function)
    }

    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        print(#function)
    }

    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print(#function)
    }
}
