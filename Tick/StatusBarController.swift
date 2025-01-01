//
//  StatusBarController.swift
//  Tick
//
//  Created by Pavel Neizhmak on 01/01/2025.
//

import Cocoa

class StatusBarController {
    private var statusItem: NSStatusItem
    private var timerManager: TimerManager

    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "Timer"
        }

        setupMenu()
        setupTimerObserver()
    }

    private func setupMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Start 5-Minute Timer", action: #selector(startFiveMinuteTimer), keyEquivalent: "5"))
        menu.addItem(NSMenuItem(title: "Stop Timer", action: #selector(stopTimer), keyEquivalent: "X"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "Q"))
        statusItem.menu = menu
    }

    @objc private func startFiveMinuteTimer() {
        timerManager.startTimer(duration: 10) // default
    }

    @objc private func stopTimer() {
        timerManager.stopTimer()
    }

    private func setupTimerObserver() {
        timerManager.onTimerUpdate = { [weak self] percentage in
            self?.updateStatusBarIcon(for: percentage)
        }
    }

    private func updateStatusBarIcon(for percentage: Double) {
        let color: NSColor = percentage > 0.5 ? .green : (percentage > 0.2 ? .yellow : .red)
        let icon = createTimerIcon(with: color)
        statusItem.button?.image = icon
    }

    private func createTimerIcon(with color: NSColor) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()
        color.setFill()
        NSBezierPath(ovalIn: NSRect(origin: .zero, size: size)).fill()
        image.unlockFocus()
        return image
    }
}

