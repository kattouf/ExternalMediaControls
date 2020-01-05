//
//  AppleScriptRunner.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 05.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Foundation
import Carbon

final class AppleScriptRunner {

    static func executeScript(named: String) {
        guard let scriptURL = Bundle.main.url(forResource: named, withExtension: "scpt"),
            let script = NSAppleScript(contentsOf: scriptURL, error: nil) else {
                return
        }

        script.executeAndReturnError(nil)
    }

    static func executeMethodFromScript(named: String,
                                        methodName: String,
                                        withParameters parameters: [String] = []) {
        guard let scriptURL = Bundle.main.url(forResource: named, withExtension: "scpt"),
            let script = NSAppleScript(contentsOf: scriptURL, error: nil) else {
                return
        }

        let eventParameters = NSAppleEventDescriptor(listDescriptor: ())
        for parameter in parameters {
            eventParameters.insert(NSAppleEventDescriptor(string: parameter), at: 0)
        }

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
        event.setParam(eventParameters, forKeyword: AEKeyword(keyDirectObject))

        script.executeAppleEvent(event, error: nil)
    }

}
