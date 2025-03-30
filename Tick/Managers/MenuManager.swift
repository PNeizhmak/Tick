//
//  MenuManager.swift
//  Tick
//
//  Created by Pavel Neizhmak on 04/01/2025.
//  Copyright © 2025 Pavel Neizhmak. All rights reserved.
//

import Cocoa

final class MenuManager {
    
    private let statusItem: NSStatusItem
    private weak var appDelegate: AppDelegate?
    private var timerItem: NSMenuItem!
    private var stopTimerItem: NSMenuItem!
    private var menu: NSMenu!
    private var presetsMenu: NSMenu!
    
    init(statusItem: NSStatusItem, appDelegate: AppDelegate) {
        self.statusItem = statusItem
        self.appDelegate = appDelegate
    }

    func setupMenu() {
        menu = NSMenu()
        setupTimerItems()
        setupQuickStartMenu()
        setupPresetsMenu()
        setupPreferencesMenu()
        setupQuitItem()
        statusItem.menu = menu
    }
    
    func updateTimerItem(with timeRemaining: TimeInterval?) {
        if let remaining = timeRemaining, remaining > 0 {
            updateActiveTimer(remaining)
        } else {
            updateInactiveTimer()
        }
    }
    
    func resetStatusBarIcon() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(named: "icon-timer")
        button.image?.isTemplate = true
        button.toolTip = "Tick App"
    }
    
    func refreshPresets() {
        updatePresetsSubmenu()
    }
    
    func updateMonitorSelection() {
        guard let monitorMenu = findMonitorSelectionMenu() else { return }
        updateMonitorSelectionItems(in: monitorMenu)
    }
    
    // MARK: - private methods
    
    private func setupTimerItems() {
        timerItem = NSMenuItem(title: "No Timer Active", action: nil, keyEquivalent: "")
        menu.addItem(timerItem)
        
        stopTimerItem = NSMenuItem(title: "Stop Timer", action: #selector(appDelegate?.stopAndResetTimer), keyEquivalent: "")
        stopTimerItem.target = appDelegate
        
        menu.addItem(NSMenuItem.separator())
    }
    
    private func setupQuickStartMenu() {
        let quickStartMenu = NSMenuItem(title: "Quick Start", action: nil, keyEquivalent: "")
        let quickStartSubmenu = NSMenu()
        
        let quickDurations = [1, 5, 30]
        for duration in quickDurations {
            let item = createQuickStartItem(duration: duration)
            quickStartSubmenu.addItem(item)
        }
        
        quickStartSubmenu.addItem(NSMenuItem.separator())
        quickStartSubmenu.addItem(createCustomDurationItem())
        
        quickStartMenu.submenu = quickStartSubmenu
        menu.addItem(quickStartMenu)
    }
    
    private func setupPresetsMenu() {
        let presetsMenuItem = NSMenuItem(title: "Timer Presets", action: nil, keyEquivalent: "")
        presetsMenu = NSMenu()
        updatePresetsSubmenu()
        presetsMenuItem.submenu = presetsMenu
        menu.addItem(presetsMenuItem)
        menu.addItem(NSMenuItem.separator())
    }
    
    private func setupPreferencesMenu() {
        let preferencesMenu = NSMenu()
        let preferencesItem = NSMenuItem(title: "Preferences", action: nil, keyEquivalent: "")
        preferencesItem.submenu = preferencesMenu
        
        setupSoundPreference(in: preferencesMenu)
        setupMonitorSelection(in: preferencesMenu)
        
        menu.addItem(preferencesItem)
    }
    
    private func setupQuitItem() {
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "q"))
    }
    
    private func updatePresetsSubmenu() {
        presetsMenu.removeAllItems()
        
        let presets = PreferencesManager.shared.getPresets()
            .sorted { $0.duration < $1.duration }
        
        if presets.isEmpty {
            addNoPresetsItem()
        } else {
            addPresetItems(presets)
        }
        
        presetsMenu.addItem(NSMenuItem.separator())
        presetsMenu.addItem(createManagePresetsItem())
    }
    
    private func updateActiveTimer(_ remaining: TimeInterval) {
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        timerItem.title = String(format: "Timer: %02d:%02d", minutes, seconds)
        
        if !menu.items.contains(stopTimerItem) {
            menu.insertItem(stopTimerItem, at: 1)
        }
    }
    
    private func updateInactiveTimer() {
        timerItem.title = "No Timer Active"
        if let index = menu.items.firstIndex(of: stopTimerItem) {
            menu.removeItem(at: index)
        }
    }
    
    private func createQuickStartItem(duration: Int) -> NSMenuItem {
        let item = NSMenuItem(
            title: "\(duration) minutes",
            action: #selector(appDelegate?.startQuickTimer),
            keyEquivalent: ""
        )
        item.target = appDelegate
        item.representedObject = duration * 60
        return item
    }
    
    private func createCustomDurationItem() -> NSMenuItem {
        let item = NSMenuItem(
            title: "Set Custom Duration...",
            action: #selector(appDelegate?.promptSetCustomDuration),
            keyEquivalent: ""
        )
        item.target = appDelegate
        return item
    }
    
    private func createManagePresetsItem() -> NSMenuItem {
        let item = NSMenuItem(
            title: "Manage Presets...",
            action: #selector(appDelegate?.showPresetManager),
            keyEquivalent: ""
        )
        item.target = appDelegate
        return item
    }
    
    private func addNoPresetsItem() {
        let noPresetsItem = NSMenuItem(title: "No Presets", action: nil, keyEquivalent: "")
        noPresetsItem.isEnabled = false
        presetsMenu.addItem(noPresetsItem)
    }
    
    private func addPresetItems(_ presets: [Preset]) {
        for preset in presets {
            let item = NSMenuItem(
                title: "\(preset.name) (\(formatDuration(preset.duration)))",
                action: #selector(appDelegate?.startPresetTimer),
                keyEquivalent: ""
            )
            item.target = appDelegate
            item.representedObject = preset
            presetsMenu.addItem(item)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func findMonitorSelectionMenu() -> NSMenu? {
        guard let preferencesItem = menu.items.first(where: { $0.title == "Preferences" }),
              let preferencesMenu = preferencesItem.submenu,
              let monitorItem = preferencesMenu.items.first(where: { $0.title == "Show Timer On" }),
              let monitorMenu = monitorItem.submenu else {
            return nil
        }
        return monitorMenu
    }
    
    private func updateMonitorSelectionItems(in menu: NSMenu) {
        menu.removeAllItems()
        let selectedMonitors = PreferencesManager.shared.getSelectedMonitors()
        
        for screen in NSScreen.screens {
            let item = NSMenuItem(
                title: screen.localizedName,
                action: #selector(appDelegate?.toggleMonitorSelection),
                keyEquivalent: ""
            )
            item.target = appDelegate
            item.state = selectedMonitors.contains(screen.localizedName) ? .on : .off
            item.representedObject = screen.localizedName
            menu.addItem(item)
        }
    }
    
    private func setupSoundPreference(in menu: NSMenu) {
        let soundItem = NSMenuItem(
            title: appDelegate?.soundPreferenceToggleTitle() ?? "Toggle Sound",
            action: #selector(appDelegate?.toggleSoundPreference),
            keyEquivalent: ""
        )
        soundItem.target = appDelegate
        menu.addItem(soundItem)
    }
    
    private func setupMonitorSelection(in menu: NSMenu) {
        let monitorSelectionSubmenu = NSMenu()
        let selectedMonitors = PreferencesManager.shared.getSelectedMonitors()
        
        for screen in NSScreen.screens {
            let item = NSMenuItem(
                title: screen.localizedName,
                action: #selector(appDelegate?.toggleMonitorSelection),
                keyEquivalent: ""
            )
            item.target = appDelegate
            item.state = selectedMonitors.contains(screen.localizedName) ? .on : .off
            item.representedObject = screen.localizedName
            monitorSelectionSubmenu.addItem(item)
        }
        
        let monitorSelectionMenu = NSMenuItem(title: "Show Timer On", action: nil, keyEquivalent: "")
        monitorSelectionMenu.submenu = monitorSelectionSubmenu
        menu.addItem(monitorSelectionMenu)
    }
}
