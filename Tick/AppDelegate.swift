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
    
    private var lastColor: NSColor = .systemGreen
    private var lastPlayedColor: NSColor?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupMenu()
        setupTimerUpdateHandler()

        overlayController = TimerOverlayController()
        overlayController.showWindow(nil)

        if UserDefaults.standard.object(forKey: "SoundsEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "SoundsEnabled")
        }
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(named: "icon-timer")
            button.image?.isTemplate = true
            button.toolTip = "Time Remaining: 00:00"
        }
    }
    
    func setupMenu() {
        let menu = NSMenu()

        let timerItem = NSMenuItem(title: "Time Remaining: 00:00", action: nil, keyEquivalent: "")
        timerItem.isEnabled = false
        menu.addItem(timerItem)

        menu.addItem(NSMenuItem.separator())

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
        menu.addItem(NSMenuItem.separator())
        
        let resetItem = NSMenuItem(title: "Stop Timer", action: #selector(stopAndResetTimer), keyEquivalent: "")
        menu.addItem(resetItem)
        
        menu.addItem(NSMenuItem.separator())
        let preferencesMenu = NSMenu()
        let soundToggleItem = NSMenuItem(
            title: soundPreferenceToggleTitle(),
            action: #selector(toggleSoundPreference),
            keyEquivalent: ""
        )
        soundToggleItem.target = self
        preferencesMenu.addItem(soundToggleItem)

        let preferencesItem = NSMenuItem(title: "Preferences", action: nil, keyEquivalent: "")
        preferencesItem.submenu = preferencesMenu
        menu.addItem(preferencesItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: ""))

        statusItem.menu = menu
    }
    
    private func soundPreferenceToggleTitle() -> String {
        let isEnabled = UserDefaults.standard.bool(forKey: "SoundsEnabled")
        return isEnabled ? "Disable sound transitions" : "Enable sound transitions"
    }

    @objc func toggleSoundPreference(_ sender: NSMenuItem) {
        let currentValue = UserDefaults.standard.bool(forKey: "SoundsEnabled")
        UserDefaults.standard.set(!currentValue, forKey: "SoundsEnabled")

        sender.title = soundPreferenceToggleTitle()
    }

    func setupTimerUpdateHandler() {
        timerManager.onTimerUpdate = { [weak self] progress in
            guard let self = self else { return }

            let newColor = self.getProgressColor(for: progress)
            
            self.updateStatusBarTitle(progress: progress)
            self.updateMenuCountdown()
            self.overlayController.update(progress: progress, color: newColor)
            
            if self.lastPlayedColor != newColor {
                self.playTransitionSound(for: newColor)
                self.lastPlayedColor = newColor
            }
        }

        timerManager.onTimerComplete = { [weak self] in
            self?.resetStatusBarIcon()
            self?.overlayController.window?.orderOut(nil)
            self?.lastPlayedColor = nil
        }
    }

    @objc func startQuickTimer(_ sender: NSMenuItem) {
        guard let duration = sender.representedObject as? Int else { return }
        startTimer(with: TimeInterval(duration))
    }

    func startTimer(with duration: TimeInterval) {
        timerManager.startTimer(duration: duration)
        overlayController.window?.orderFront(nil)

        if let button = statusItem.button {
            button.image = nil
            button.title = "🟢"
        }

        let initialProgress = 1.0
        let initialColor = getProgressColor(for: initialProgress)
        overlayController.update(progress: initialProgress, color: initialColor)

        playTransitionSound(for: initialColor)
        lastPlayedColor = initialColor
    }

    @objc func promptSetCustomDuration() {
        let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                            styleMask: [.titled, .closable],
                            backing: .buffered,
                            defer: false)
        panel.title = "Set Timer Duration"

        let descriptionLabel = NSTextField(labelWithString: "Set the duration for the timer:")
        descriptionLabel.frame = NSRect(x: 50, y: 150, width: 200, height: 20)
        descriptionLabel.alignment = .center
        descriptionLabel.isEditable = false

        let timePicker = NSDatePicker()
        timePicker.datePickerMode = .single
        timePicker.datePickerElements = [.hourMinuteSecond]
        timePicker.dateValue = Calendar.current.date(from: DateComponents(hour: 0, minute: 5)) ?? Date()
        timePicker.frame = NSRect(x: 50, y: 100, width: 200, height: 30)

        let hintLabel = NSTextField(labelWithString: "Hours : Minutes : Seconds")
        hintLabel.frame = NSRect(x: 50, y: 70, width: 200, height: 20)
        hintLabel.alignment = .center
        hintLabel.font = NSFont.systemFont(ofSize: 10)
        hintLabel.textColor = NSColor.secondaryLabelColor

        let okButton = NSButton(title: "OK", target: self, action: #selector(confirmTimePickerDuration))
        okButton.frame = NSRect(x: 100, y: 30, width: 100, height: 30)

        if let contentView = panel.contentView {
            contentView.addSubview(descriptionLabel)
            contentView.addSubview(timePicker)
            contentView.addSubview(hintLabel)
            contentView.addSubview(okButton)
        }

        timePicker.tag = 1001
        panel.isFloatingPanel = true

        NSApp.runModal(for: panel)
    }

    @objc func confirmTimePickerDuration(_ sender: NSButton) {
        guard let panel = sender.window as? NSPanel,
              let timePicker = panel.contentView?.viewWithTag(1001) as? NSDatePicker else { return }

        let selectedDate = timePicker.dateValue
        let calendar = Calendar.current

        let components = calendar.dateComponents([.hour, .minute, .second], from: selectedDate)
        let totalSeconds = (components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60 + (components.second ?? 0)

        guard totalSeconds > 0 else {
            showInvalidDurationError(message: "Please select a duration greater than 0.")
            return
        }

        startTimer(with: TimeInterval(totalSeconds))

        panel.close()
        NSApp.stopModal()
    }

    func showInvalidDurationError(message: String) {
        let errorAlert = NSAlert()
        errorAlert.messageText = "Invalid Duration"
        errorAlert.informativeText = message
        errorAlert.alertStyle = .critical
        errorAlert.addButton(withTitle: "OK")
        errorAlert.runModal()
    }

    @objc func stopAndResetTimer() {
        timerManager.stopTimer()

        resetStatusBarIcon()
        overlayController.update(progress: 0.0, color: .systemBlue)
        overlayController.window?.orderOut(nil)
        lastPlayedColor = nil
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

    func updateMenuCountdown() {
        if let menu = statusItem.menu, let timerItem = menu.items.first {
            let minutes = Int(timerManager.remainingTime) / 60
            let seconds = Int(timerManager.remainingTime) % 60
            timerItem.title = String(format: "Time Remaining: %02d:%02d", minutes, seconds)
        }
    }

    func resetStatusBarIcon() {
        if let button = statusItem.button {
            button.title = ""
            button.image = NSImage(named: "icon-timer")
            button.image?.isTemplate = true
            button.toolTip = "Time Remaining: 00:00"
        }

        if let menu = statusItem.menu, let timerItem = menu.items.first {
            timerItem.title = "Time Remaining: 00:00"
        }
    }

    private func getProgressColor(for progress: Double) -> NSColor {
        let greenThreshold: Double = 0.5
        let yellowThreshold: Double = 0.2

        if progress > greenThreshold {
            return .systemGreen
        } else if progress > yellowThreshold {
            return .systemYellow
        } else {
            return .systemRed
        }
    }
    
    private func playTransitionSound(for color: NSColor) {
        guard UserDefaults.standard.bool(forKey: "SoundsEnabled") else {
            print("Sounds are disabled. No sound will be played.")
            return
        }

        let soundName: String
        switch color {
        case .systemGreen:
            soundName = "Submarine"
        case .systemYellow:
            soundName = "Ping"
        case .systemRed:
            soundName = "Basso"
        default:
            return
        }

        guard let sound = NSSound(named: soundName) else {
            print("Sound \(soundName) not found! Defaulting to system beep.")
            NSSound.beep()
            return
        }

        sound.stop()
        sound.play()
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal()
    }
}
