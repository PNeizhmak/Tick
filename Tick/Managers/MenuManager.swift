//
//  MenuManager.swift
//  Tick
//
//  Created by Pavel Neizhmak on 04/01/2025.
//

import Cocoa

class MenuManager {
    private let statusItem: NSStatusItem
    private let appDelegate: AppDelegate
    private var timerItem: NSMenuItem!
    
    init(statusItem: NSStatusItem, appDelegate: AppDelegate) {
        self.statusItem = statusItem
        self.appDelegate = appDelegate
    }

    func setupMenu() {
        let menu = NSMenu()

        timerItem = NSMenuItem(title: "Time Remaining: 00:00", action: nil, keyEquivalent: "")
        timerItem.isEnabled = false
        menu.addItem(timerItem)

        menu.addItem(NSMenuItem.separator())

        let quickStartMenu = NSMenuItem(title: "Quick Start", action: nil, keyEquivalent: "")
        let quickStartSubmenu = NSMenu()

        let quickDurations = [1, 5, 10, 30]
        quickDurations.forEach { minutes in
            let item = NSMenuItem(
                title: "\(minutes) min",
                action: #selector(appDelegate.startQuickTimer),
                keyEquivalent: ""
            )
            item.representedObject = minutes * 60
            quickStartSubmenu.addItem(item)
        }

        quickStartMenu.submenu = quickStartSubmenu
        menu.addItem(quickStartMenu)

        menu.addItem(NSMenuItem(title: "Set Timer Duration...", action: #selector(appDelegate.promptSetCustomDuration), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        let resetItem = NSMenuItem(title: "Stop Timer", action: #selector(appDelegate.stopAndResetTimer), keyEquivalent: "")
        menu.addItem(resetItem)

        menu.addItem(NSMenuItem.separator())
        let preferencesMenu = NSMenu()
        let soundToggleItem = NSMenuItem(
            title: appDelegate.soundPreferenceToggleTitle(),
            action: #selector(appDelegate.toggleSoundPreference),
            keyEquivalent: ""
        )
        soundToggleItem.target = appDelegate
        preferencesMenu.addItem(soundToggleItem)

        let monitorSelectionSubmenu = NSMenu()
        let selectedMonitors = PreferencesManager.shared.getSelectedMonitors()
        
        print("Setting up monitor selection menu")
        print("Selected monitors: \(selectedMonitors)")
        print("Available screens: \(NSScreen.screens.map { $0.localizedName })")
        
        for screen in NSScreen.screens {
            let item = NSMenuItem(
                title: screen.localizedName,
                action: #selector(appDelegate.toggleMonitorSelection),
                keyEquivalent: ""
            )
            item.state = selectedMonitors.contains(screen.localizedName) ? .on : .off
            item.representedObject = screen.localizedName
            monitorSelectionSubmenu.addItem(item)
            print("Added menu item for screen: \(screen.localizedName), state: \(item.state.rawValue)")
        }

        let monitorSelectionMenu = NSMenuItem(title: "Select Monitors", action: nil, keyEquivalent: "")
        monitorSelectionMenu.submenu = monitorSelectionSubmenu
        preferencesMenu.addItem(monitorSelectionMenu)

        let preferencesItem = NSMenuItem(title: "Preferences", action: nil, keyEquivalent: "")
        preferencesItem.submenu = preferencesMenu
        menu.addItem(preferencesItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: ""))

        statusItem.menu = menu
    }
    
    func updateTimerItem(with timeRemaining: TimeInterval) {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        timerItem.title = String(format: "Time Remaining: %02d:%02d", minutes, seconds)
    }
    
    private func soundPreferenceToggleTitle() -> String {
        let isEnabled = UserDefaults.standard.bool(forKey: "SoundsEnabled")
        return isEnabled ? "Disable sound transitions" : "Enable sound transitions"
    }
}
