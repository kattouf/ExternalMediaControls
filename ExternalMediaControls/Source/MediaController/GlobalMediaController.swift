//
//  GlobalMediaController.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 04.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Cocoa
import AudioToolbox

private struct Keytype {
    static let soundUp: Int32 = NX_KEYTYPE_SOUND_UP
    static let soundDown: Int32 = NX_KEYTYPE_SOUND_DOWN
    static let play: Int32 = NX_KEYTYPE_PLAY
    static let next: Int32 = NX_KEYTYPE_NEXT
    static let previous: Int32 = NX_KEYTYPE_PREVIOUS
}

final class GlobalMediaController: MediaController {

    // MARK: - MediaController
    func handle(command: MediaCommand) {
        switch command {
        case .prev:
            simulateKeyClick(Keytype.previous)
        case .play:
            simulateKeyClick(Keytype.play)
        case .next:
            simulateKeyClick(Keytype.next)
        case .volumeUp:
            simulateKeyClick(Keytype.soundUp)
        case .volumeDown:
            simulateKeyClick(Keytype.soundDown)
        case .volume:
            break
        }
    }

    // MARK: - Private methods
    private func simulateKeyClick(_ key: Int32) {
        func doKey(down: Bool) {
            let flags = NSEvent.ModifierFlags(rawValue: (down ? 0xa00 : 0xb00))
            let data1 = Int((key << 16) | (down ? 0xa00 : 0xb00))

            let ev = NSEvent.otherEvent(with: .systemDefined,
                                        location: .zero,
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

    private func setGlobalVolume(_ value: Float) {
        var volume = value
        let volumeSize = UInt32(MemoryLayout.size(ofValue: volume))

        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMaster)

        AudioObjectSetPropertyData(
            Self.defaultOutputDeviceID,
            &volumePropertyAddress,
            0,
            nil,
            volumeSize,
            &volume)

    }

    private func getGlobalVolume() -> Float {
        var volume = Float32(0.0)
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))

        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMaster)

        AudioObjectGetPropertyData(
            Self.defaultOutputDeviceID,
            &volumePropertyAddress,
            0,
            nil,
            &volumeSize,
            &volume)

        return volume
    }

    private static let defaultOutputDeviceID: AudioObjectID = {
        var defaultOutputDeviceID = AudioDeviceID(0)
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))

        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &getDefaultOutputDevicePropertyAddress,
            0,
            nil,
            &defaultOutputDeviceIDSize,
            &defaultOutputDeviceID)
        return defaultOutputDeviceID
    }()
}
