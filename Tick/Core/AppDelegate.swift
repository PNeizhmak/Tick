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
    var menuManager: MenuManager!
    var timerController: TimerController!
    var statusBarManager: StatusBarManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()

        menuManager = MenuManager(statusItem: statusItem, appDelegate: self)
        menuManager.setupMenu()

        overlayController = TimerOverlayController()
        timerController = TimerController(timerManager: timerManager, overlayController: overlayController)
        statusBarManager = StatusBarManager(statusItem: statusItem, timerManager: timerManager)

        if UserDefaults.standard.object(forKey: "SoundsEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "SoundsEnabled")
        }

        checkForUpdatesAutomatically()
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(named: "icon-timer")
            button.image?.isTemplate = true
            button.toolTip = "Time Remaining: 00:00"
        }
    }

    func checkForUpdatesAutomatically() {
        UpdateManager.shared.checkForUpdates { isUpdateAvailable, latestVersion, downloadURL in
            DispatchQueue.main.async {
                if isUpdateAvailable, let latestVersion = latestVersion, let downloadURL = downloadURL {
                    self.promptUpdate(latestVersion: latestVersion, downloadURL: downloadURL)
                }
            }
        }
    }

    func promptUpdate(latestVersion: String, downloadURL: String) {
        let alert = NSAlert()
        alert.messageText = "Update Available"
        alert.informativeText = "A newer version of Tick (\(latestVersion)) is available. Would you like to download it?"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Download")
        alert.addButton(withTitle: "Ignore This Update")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: downloadURL) {
                NSWorkspace.shared.open(url)
            }
        } else if response == .alertSecondButtonReturn {
            UpdateManager.shared.ignoreUpdate(version: latestVersion)
        }
    }

    @objc func startQuickTimer(_ sender: NSMenuItem) {
        guard let duration = sender.representedObject as? Int else { return }
        timerController.startTimer(duration: TimeInterval(duration))
    }

    @objc func promptSetCustomDuration() {
        let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                            styleMask: [.titled, .closable],
                            backing: .buffered,
                            defer: false)
        panel.title = "Set Timer Duration"
        panel.delegate = self
        
        let descriptionLabel = NSTextField(labelWithString: "Set the duration for the timer:")
        descriptionLabel.frame = NSRect(x: 50, y: 150, width: 200, height: 20)
        descriptionLabel.alignment = .center
        descriptionLabel.isEditable = false

        let timePicker = NSDatePicker()
        timePicker.datePickerMode = .single
        timePicker.datePickerElements = [.hourMinuteSecond]
        timePicker.dateValue = Calendar.current.date(from: DateComponents(hour: 0, minute: 20)) ?? Date()
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

        timerController.startTimer(duration: TimeInterval(totalSeconds))

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
        timerController.stopTimer()
        statusBarManager.resetStatusBarIcon()
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal()
    }
}

extension AppDelegate {
    func soundPreferenceToggleTitle() -> String {
        return PreferencesManager.shared.soundPreferenceToggleTitle()
    }

    @objc func toggleSoundPreference(_ sender: NSMenuItem) {
        PreferencesManager.shared.toggleSoundPreference()
        sender.title = PreferencesManager.shared.soundPreferenceToggleTitle()
    }
}
