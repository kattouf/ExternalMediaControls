//
//  GlobalMediaControls.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 04.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Cocoa

private struct Keytype {
    static let soundUp: UInt32 = 0
    static let soundDown: UInt32 = 1
    static let play: UInt32 = 16
    static let next: UInt32 = 17
    static let previous: UInt32 = 18
    static let fast: UInt32 = 19
    static let rewind: UInt32 = 20
}

final class GlobalMediaControls: MediaControls {

    // MARK: - MediaControls
    func prev() {
        simulateKeyClick(Keytype.previous)
    }

    func play() {
        simulateKeyClick(Keytype.play)
    }

    func next() {
        simulateKeyClick(Keytype.next)
    }

    // MARK: - Private methods
    private func simulateKeyClick(_ key: UInt32) {
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
