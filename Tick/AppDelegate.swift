//
//  AppDelegate.swift
//  Tick
//
//  Created by Pavel Neizhmak on 01/01/2025.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var timerManager = TimerManager()
    var overlayController: TimerOverlayController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupMenu()
        setupOverlay()
        setupTimerUpdateHandler()
    }

    func setupStatusItem() {
        // Create the menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "⏱"
            button.toolTip = "Simple timer"
        }
    }

    func setupMenu() {
        let menu = NSMenu()

        // Timer countdown menu item
        let timerItem = NSMenuItem(title: "Time Remaining: 00:00", action: nil, keyEquivalent: "")
        timerItem.isEnabled = false
        menu.addItem(timerItem)

        // Start, stop, and quit options
        menu.addItem(NSMenuItem(title: "Start Timer", action: #selector(startTimer), keyEquivalent: "S"))
        menu.addItem(NSMenuItem(title: "Stop Timer", action: #selector(stopTimer), keyEquivalent: "X"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "Q"))

        statusItem.menu = menu
    }

    func setupOverlay() {
        overlayController = TimerOverlayController()
        overlayController.showWindow(nil)
    }

    func setupTimerUpdateHandler() {
        timerManager.onTimerUpdate = { [weak self] progress in
            self?.updateStatusBarTitle(progress: progress)
            self?.updateMenuCountdown()
            self?.updateOverlay(progress: progress)
        }
        timerManager.onTimerComplete = { [weak self] in
            self?.resetStatusBarIcon()
            self?.overlayController.window?.orderOut(nil)
        }
    }

    @objc func startTimer() {
        timerManager.startTimer(duration: 30)
        overlayController.window?.orderFront(nil)
    }

    @objc func stopTimer() {
        timerManager.stopTimer()
    }

    func updateStatusBarTitle(progress: Double) {
        if let button = statusItem.button {
            let title: String
            if progress > 0.5 {
                title = "🟢"
            } else if progress > 0.2 {
                title = "🟡"
            } else {
                title = "🔴"
            }
            button.title = title
        }
    }

    func updateMenuCountdown() {
        if let menu = statusItem.menu, let timerItem = menu.items.first {
            let minutes = Int(timerManager.remainingTime) / 60
            let seconds = Int(timerManager.remainingTime) % 60
            timerItem.title = String(format: "Time Remaining: %02d:%02d", minutes, seconds)
        }
    }

    func updateOverlay(progress: Double) {
        let color: NSColor
        if progress > 0.5 {
            color = .systemGreen
        } else if progress > 0.2 {
            color = .systemYellow
        } else {
            color = .systemRed
        }
        overlayController.update(progress: progress, color: color)
    }

    func resetStatusBarIcon() {
        if let button = statusItem.button {
            button.title = "⏱"
        }

        if let menu = statusItem.menu, let timerItem = menu.items.first {
            timerItem.title = "Time Remaining: 00:00"
        }
    }
}

