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

    func updateStatusBarTitle(progress: Double) {
        guard let button = statusItem.button else { return }

        if progress > 0.5 {
            button.title = "🟢"
        } else if progress > 0.2 {
            button.title = "🟡"
        } else {
            button.title = "🔴"
        }

        button.image = nil
        let minutes = Int(timerManager.remainingTime) / 60
        let seconds = Int(timerManager.remainingTime) % 60
        button.toolTip = String(format: "Time Remaining: %02d:%02d", minutes, seconds)
    }

    func resetStatusBarIcon() {
        if let button = statusItem.button {
            button.title = ""
            button.image = NSImage(named: "icon-timer")
            button.image?.isTemplate = true
            button.toolTip = "Time Remaining: 00:00"
        }
    }
}
