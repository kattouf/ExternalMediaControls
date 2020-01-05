//
//  MediaController.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 04.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Foundation

protocol MediaController: class {
    var didReceiveCommand: ((MediaCommand) -> Void)? { get set }

    func start()
    func stop()

    func showUIState(_ state: MediaUIState)
}
