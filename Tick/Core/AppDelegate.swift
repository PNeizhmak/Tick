//
//  AppDelegate.swift
//  Tick
//
//  Created by Pavel Neizhmak on 01/01/2025.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var timerManager = TimerManager()
    var overlayController: TimerOverlayController!
    var menuManager: MenuManager!
    var timerController: TimerController!
    private var presetManagerWindow: NSWindow?
    private var setTimerWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        
        menuManager = MenuManager(statusItem: statusItem, appDelegate: self)
        menuManager.setupMenu()

        overlayController = TimerOverlayController(timerManager: timerManager)
        timerController = TimerController(timerManager: timerManager, overlayController: overlayController)
        
        timerController.addTimerUpdateHandler { [weak self] progress in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.menuManager.updateTimerItem(with: self.timerManager.remainingTime)
            }
        }
        
        if UserDefaults.standard.object(forKey: "SoundsEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "SoundsEnabled")
        }

        checkForUpdatesAutomatically()
        
        // Setup notification observer for preset changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presetsDidChange),
            name: PreferencesManager.Notifications.presetsDidChange,
            object: nil
        )
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(named: "icon-timer")
            button.image?.isTemplate = true
            button.toolTip = "Tick App"
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
        if let existingWindow = setTimerWindow {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let setTimerView = SetTimerView(isPresented: .init(get: {
            return self.setTimerWindow != nil
        }, set: { isPresented in
            if !isPresented {
                self.setTimerWindow?.close()
                self.setTimerWindow = nil
            }
        })) { duration in
            self.timerController.startTimer(duration: duration)
        }
        
        let hostingController = NSHostingController(rootView: setTimerView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hostingController
        window.title = "Custom Duration"
        window.isReleasedWhenClosed = false
        window.center()
        
        setTimerWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func stopAndResetTimer() {
        timerController.stopTimer()
        menuManager.resetStatusBarIcon()
        menuManager.updateTimerItem(with: nil)
    }

    @objc func togglePauseTimer() {
        if timerManager.isTimerRunning {
            timerController.pauseTimer()
        } else {
            timerController.resumeTimer()
        }
        menuManager.updateTimerItem(with: timerManager.remainingTime)
    }

    @objc func startPresetTimer(_ sender: NSMenuItem) {
        guard let preset = sender.representedObject as? Preset else { return }
        timerController.startTimer(duration: preset.duration)
    }

    @objc func showPresetManager() {
        if let existingWindow = presetManagerWindow {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let presetManager = PresetManager()
        let hostingController = NSHostingController(rootView: presetManager)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hostingController
        window.title = "Timer Presets"
        window.isReleasedWhenClosed = false
        window.center()
        
        presetManagerWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func presetsDidChange() {
        menuManager.refreshPresets()
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

    @objc func toggleMonitorSelection(_ sender: NSMenuItem) {
        guard let monitorName = sender.representedObject as? String else { return }
        var selectedMonitors = PreferencesManager.shared.getSelectedMonitors()
        
        if sender.state == .on {
            selectedMonitors.remove(monitorName)
            print("Removed monitor: \(monitorName)")
        } else {
            selectedMonitors.insert(monitorName)
            print("Added monitor: \(monitorName)")
        }
        
        if selectedMonitors.isEmpty {
            if let builtInDisplay = NSScreen.screens.first(where: { $0.localizedName.contains("Built-in") }) {
                selectedMonitors.insert(builtInDisplay.localizedName)
                print("No monitors selected, defaulting to built-in display: \(builtInDisplay.localizedName)")
            }
        }
        
        print("Selected monitors: \(selectedMonitors)")
        PreferencesManager.shared.setSelectedMonitors(selectedMonitors)
        overlayController.refreshWindows()
        
        menuManager.updateMonitorSelection()
    }
}
