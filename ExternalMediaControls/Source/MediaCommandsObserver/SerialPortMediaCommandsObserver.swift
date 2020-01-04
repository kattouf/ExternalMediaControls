//
//  SerialPortMediaCommandsObserver.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 04.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Foundation
import ORSSerial

final class SerialPortMediaCommandsObserver: NSObject, MediaCommandsObserver {
    // MARK: - Private properties
    private var port: ORSSerialPort?

    // MARK: - MediaCommandsObserver
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

}

// MARK: - ORSSerialPortDelegate
extension SerialPortMediaCommandsObserver: ORSSerialPortDelegate {

    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        // use didReceivePacket instead
    }

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

private extension SerialPortMediaCommandsObserver {

    func parseCommand(from receivedData: Data) -> MediaCommand? {
        let receivedString = String(data: receivedData, encoding: .utf8)

        switch receivedString {
        case "101":
            return .prev
        case "102":
            return .play
        case "103":
            return .next
        default:
            return .none
        }
    }
}
