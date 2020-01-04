//
//  MediaController.swift
//  ExternalMediaButtons
//
//  Created by Vasiliy Yanguzin on 04.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Foundation

protocol MediaController {
    func handle(command: MediaCommand)
}
