//
//  MediaUIChange.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 05.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Foundation

enum MediaUIChange {
    case isPlaying(Bool)
    case isLiked(Bool)
    case trackInfo(title: String, artist: String)
}
