//
//  StatusBarManager.swift
//  Tick
//
//  Created by Pavel Neizhmak on 07/01/2025.
//

import Cocoa

class StatusBarManager {
    private let statusItem: NSStatusItem
    private let timerManager: TimerManager

    init(statusItem: NSStatusItem, timerManager: TimerManager) {
        self.statusItem = statusItem
        self.timerManager = timerManager
    }

    func resetStatusBarIcon() {
        if let button = statusItem.button {
            button.title = ""
            button.image = NSImage(named: "icon-timer")
            button.image?.isTemplate = true
        }
    }
}
