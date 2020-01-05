//
//  MediaCommand.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 05.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Foundation

enum MediaCommand {
    case prev
    case play
    case next
    case volumeUp
    case volumeDown
    case volume(value: Float)
}
