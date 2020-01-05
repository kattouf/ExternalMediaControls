//
//  StatusMenuController.swift
//  ExternalMediaControls
//
//  Created by Vasiliy Yanguzin on 04.01.2020.
//  Copyright © 2020 Vasiliy Yanguzin. All rights reserved.
//

import Cocoa

final class StatusMenuController: NSObject {
    // MARK: - Private propeties
    @IBOutlet private weak var statusMenu: NSMenu?

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    // MARK: - Overrides
    override func awakeFromNib() {
        statusItem.button?.image = NSImage(named: "StatusMenuIcon")
        statusItem.menu = statusMenu
    }

    // MARK: - Actions
    @IBAction private func didClickQuitMenuItem(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
