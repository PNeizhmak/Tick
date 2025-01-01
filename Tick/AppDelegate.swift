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
        setupTimerUpdateHandler()

        overlayController = TimerOverlayController()
        overlayController.showWindow(nil)
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "⏱"
            button.toolTip = "Time Remaining: 00:00"
        }
    }

    func setupMenu() {
        let menu = NSMenu()

        let timerItem = NSMenuItem(title: "Time Remaining: 00:00", action: nil, keyEquivalent: "")
        timerItem.isEnabled = false
        menu.addItem(timerItem)

        let quickStartMenu = NSMenuItem(title: "Quick Start", action: nil, keyEquivalent: "")
        let quickStartSubmenu = NSMenu()

        let quickDurations = [1, 5, 10]
        quickDurations.forEach { minutes in
            let item = NSMenuItem(
                title: "\(minutes) min",
                action: #selector(startQuickTimer),
                keyEquivalent: ""
            )
            item.representedObject = minutes * 60
            quickStartSubmenu.addItem(item)
        }

        quickStartMenu.submenu = quickStartSubmenu
        menu.addItem(quickStartMenu)

        menu.addItem(NSMenuItem(title: "Set Timer Duration...", action: #selector(promptSetCustomDuration), keyEquivalent: ""))

        let resetItem = NSMenuItem(title: "Stop/Reset Timer", action: #selector(stopAndResetTimer), keyEquivalent: "R")
        menu.addItem(resetItem)

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "Q"))

        statusItem.menu = menu
    }

    func setupTimerUpdateHandler() {
        timerManager.onTimerUpdate = { [weak self] progress in
            self?.updateStatusBarTitle(progress: progress)
            self?.updateMenuCountdown()
            self?.overlayController.update(progress: progress, color: self?.getProgressColor(for: progress) ?? .systemBlue)
        }
        timerManager.onTimerComplete = { [weak self] in
            self?.resetStatusBarIcon()
            self?.overlayController.window?.orderOut(nil)
        }
    }

    @objc func startQuickTimer(_ sender: NSMenuItem) {
        guard let duration = sender.representedObject as? Int else { return }
        startTimer(with: TimeInterval(duration))
    }

    func startTimer(with duration: TimeInterval) {
        timerManager.startTimer(duration: duration)
        overlayController.window?.orderFront(nil)
    }

    @objc func promptSetCustomDuration() {
        let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                            styleMask: [.titled, .closable],
                            backing: .buffered,
                            defer: false)
        panel.title = "Set Timer Duration"

        let timePicker = NSDatePicker()
        timePicker.datePickerMode = .single
        timePicker.datePickerElements = [.hourMinuteSecond]
        timePicker.dateValue = Calendar.current.date(from: DateComponents(hour: 0, minute: 5)) ?? Date()
        timePicker.frame = NSRect(x: 50, y: 90, width: 200, height: 30)

        let okButton = NSButton(title: "OK", target: self, action: #selector(confirmTimePickerDuration))
        okButton.frame = NSRect(x: 100, y: 30, width: 100, height: 30)

        if let contentView = panel.contentView {
            contentView.addSubview(timePicker)
            contentView.addSubview(okButton)
        }

        panel.isFloatingPanel = true

        NSApp.runModal(for: panel)
    }

    @objc func confirmTimePickerDuration(_ sender: NSButton) {
        guard let panel = sender.window as? NSPanel,
              let timePicker = panel.contentView?.subviews.first(where: { $0 is NSDatePicker }) as? NSDatePicker else { return }

        let selectedDate = timePicker.dateValue
        let calendar = Calendar.current

        let components = calendar.dateComponents([.hour, .minute, .second], from: selectedDate)
        let totalSeconds = (components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60 + (components.second ?? 0)

        guard totalSeconds > 0 else {
            showInvalidDurationError()
            return
        }

        UserDefaults.standard.set(totalSeconds, forKey: "timerDuration")
        startTimer(with: TimeInterval(totalSeconds))

        panel.close()
        NSApp.stopModal()
    }

    func showInvalidDurationError() {
        let errorAlert = NSAlert()
        errorAlert.messageText = "Invalid Duration"
        errorAlert.informativeText = "Please select a duration greater than 0."
        errorAlert.alertStyle = .critical
        errorAlert.addButton(withTitle: "OK")
        errorAlert.runModal()
    }

    @objc func stopAndResetTimer() {
        timerManager.stopTimer()

        resetStatusBarIcon()
        overlayController.update(progress: 0.0, color: .systemBlue) // Reset progress to 0
        overlayController.window?.orderOut(nil)
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

            // Update toolTip with the remaining time
            let minutes = Int(timerManager.remainingTime) / 60
            let seconds = Int(timerManager.remainingTime) % 60
            button.toolTip = String(format: "Time Remaining: %02d:%02d", minutes, seconds)
        }
    }

    func updateMenuCountdown() {
        if let menu = statusItem.menu, let timerItem = menu.items.first {
            let minutes = Int(timerManager.remainingTime) / 60
            let seconds = Int(timerManager.remainingTime) % 60
            timerItem.title = String(format: "Time Remaining: %02d:%02d", minutes, seconds)
        }
    }

    func resetStatusBarIcon() {
        if let button = statusItem.button {
            button.title = "⏱"
            button.toolTip = "Time Remaining: 00:00"
        }

        if let menu = statusItem.menu, let timerItem = menu.items.first {
            timerItem.title = "Time Remaining: 00:00"
        }
    }

    private func getProgressColor(for progress: Double) -> NSColor {
        if progress > 0.5 {
            return .systemGreen
        } else if progress > 0.2 {
            return .systemYellow
        } else {
            return .systemRed
        }
    }
}
