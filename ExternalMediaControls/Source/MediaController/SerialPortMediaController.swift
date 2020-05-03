//
//  SerialPortMediaController.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 04.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Foundation
import ORSSerial

final class SerialPortMediaController: NSObject, MediaController {
    // MARK: - Private properties
    private var port: ORSSerialPort?
    private var availablePortsObervation: NSKeyValueObservation?

    // MARK: - MediaController
    var didReceiveCommand: ((MediaCommand) -> Void)?

    func start() {
        if !findAppropriatePortAndConnect() {
            startObservingAvailablePorts()
        }
    }

    func stop() {
        port?.close()
        port = nil

        stopObservingAvailablePorts()
    }

    func updateUI(_ change: MediaUIChange) {
        switch change {
        case .like(let value):
            updateLike(value)
        case .trackInfo(let title, let author):
            updateTrackInfo(title: title, author: author)
        }
    }
}

// MARK: - ORSSerialPortDelegate
extension SerialPortMediaController: ORSSerialPortDelegate {

    func serialPort(_ serialPort: ORSSerialPort,
                    didReceivePacket packetData: Data,
                    matching descriptor: ORSSerialPacketDescriptor) {
        guard let parsedCommand = parseCommand(from: packetData) else {
            print("Cannot parse data from port")
            return
        }

        didReceiveCommand?(parsedCommand)
    }

    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        port = nil
        print("Port was removed from system")

        startObservingAvailablePorts()
    }

    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        print("Port was opened")
    }

    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        print("Port was closed")
    }

    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Port did encounter error: \(error.localizedDescription)")
    }
}

// MARK: - Private methods
private extension SerialPortMediaController {

    func startObservingAvailablePorts() {
        print("start waiting appropriate port")
        availablePortsObervation = ORSSerialPortManager.shared().observe(\.availablePorts) { _, change in
            if self.findAppropriatePortAndConnect() {
                self.stopObservingAvailablePorts()
            }
        }
    }

    func stopObservingAvailablePorts() {
        print("stop waiting appropriate port")
        availablePortsObervation = nil
    }

    @discardableResult
    func findAppropriatePortAndConnect() -> Bool {
        // TODO: pick port via UI
        guard let port = ORSSerialPortManager.shared().availablePorts.first(where: { $0.path.starts(with: "/dev/cu.usbmodem") }) else {
            print("cannot find appropriate port")
            return false
        }

        port.baudRate = 9600
        port.delegate = self
        port.open()

        let packetRegex = try! NSRegularExpression(pattern: #"^\d{3}"#, options: [])
        let packetDescriptor = ORSSerialPacketDescriptor(regularExpression: packetRegex,
                                                         maximumPacketLength: 3,
                                                         userInfo: nil)
        port.startListeningForPackets(matching: packetDescriptor)

        self.port = port

        return true
    }

    func parseCommand(from receivedData: Data) -> MediaCommand? {
        guard let receivedString = String(data: receivedData, encoding: .utf8),
            let code = Int(receivedString) else {
                return nil
        }

        switch code {
        case 101:
            return .prev
        case 102:
            return .play
        case 103:
            return .next
        case 104:
            return .volumeDown
        case 105:
            return .volumeUp
        case 106:
            return .like
        case 200...299:
            return .volume(value: Float(code - 200) / Float(299 - 200))
        default:
            return nil
        }
    }

    func updateLike(_ value: Bool) {
        sendDataString("[101]{\(value ? 1 : 0)}")
    }

    func updateTrackInfo(title: String, author: String) { // todo: artist
        let latinTitle = title
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripDiacritics, reverse: false)
            ?? title
        let latinArtist = author
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripDiacritics, reverse: false) ?? author
        sendDataString("[102]{\(latinTitle)<~>\(latinArtist)}")
    }

    func sendDataString(_ dataString: String) {
        guard
            let data = dataString.data(using: .nonLossyASCII)
        else {
            return
        }
        port?.send(data)
    }
}
