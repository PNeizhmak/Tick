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

    init(statusItem: NSStatusItem, appDelegate: AppDelegate) {
        self.statusItem = statusItem
        self.appDelegate = appDelegate
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
}
