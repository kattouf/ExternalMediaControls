//
//  AppDelegate.swift
//  ExternalMediaButtons
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

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // todo: use manager
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
            clickMediaPrev()
        case "2":
            clickMediaPlay()
        case "1":
            clickMediaNext()
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

// MARK: - Media button events generator
private extension AppDelegate {

    static let NX_KEYTYPE_SOUND_UP: UInt32 = 0
    static let NX_KEYTYPE_SOUND_DOWN: UInt32 = 1
    static let NX_KEYTYPE_PLAY: UInt32 = 16
    static let NX_KEYTYPE_NEXT: UInt32 = 17
    static let NX_KEYTYPE_PREVIOUS: UInt32 = 18
    static let NX_KEYTYPE_FAST: UInt32 = 19
    static let NX_KEYTYPE_REWIND: UInt32 = 20

    func clickMediaPrev() {
        simulateKeyClick(Self.NX_KEYTYPE_PREVIOUS)
    }

    func clickMediaPlay() {
        simulateKeyClick(Self.NX_KEYTYPE_PLAY)
    }

    func clickMediaNext() {
        simulateKeyClick(Self.NX_KEYTYPE_NEXT)
    }

    func simulateKeyClick(_ key: UInt32) {
        func doKey(down: Bool) {
            let flags = NSEvent.ModifierFlags(rawValue: (down ? 0xa00 : 0xb00))
            let data1 = Int((key<<16) | (down ? 0xa00 : 0xb00))

            let ev = NSEvent.otherEvent(with: NSEvent.EventType.systemDefined,
                                        location: NSPoint(x:0,y:0),
                                        modifierFlags: flags,
                                        timestamp: 0,
                                        windowNumber: 0,
                                        context: nil,
                                        subtype: 8,
                                        data1: data1,
                                        data2: -1
            )
            let cev = ev?.cgEvent
            cev?.post(tap: CGEventTapLocation.cghidEventTap)
        }

        doKey(down: true)
        doKey(down: false)
    }
}
