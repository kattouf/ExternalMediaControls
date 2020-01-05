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

    // MARK: - MediaController
    var didReceiveCommand: ((MediaCommand) -> Void)?

    func start() {
        guard let port = ORSSerialPortManager.shared().availablePorts.first(where: { $0.path == "/dev/cu.usbmodem144101" }) else {
            print("cannot connect to port")
            return
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
    }

    func stop() {
        port?.close()
        port = nil
    }

    func showUIState(_ state: MediaUIState) {
        switch state {
        case .liked(let value):
            showLikedState(value)
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

    func showLikedState(_ value: Bool) {
        if let data = "\(value ? 101 : 102)".data(using: .utf8) {
            port?.send(data)
        }
    }
}
