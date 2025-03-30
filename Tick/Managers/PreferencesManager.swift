//
//  PreferencesManager.swift
//  Tick
//
//  Created by Pavel Neizhmak on 07/01/2025.
//

import Foundation
import AppKit

class PreferencesManager {
    static let shared = PreferencesManager()

    enum Notifications {
        static let presetsDidChange = Notification.Name("com.tick.presets.didChange")
    }

    private let presetsKey = "TimerPresets"

    private init() {
        if getPresets().isEmpty {
            let defaultPresets = [
                Preset(name: "Meeting", duration: 25 * 60), // 25 minutes
                Preset(name: "Break", duration: 15 * 60),   // 15 minutes
                Preset(name: "Focus time", duration: 50 * 60)  // 50 minutes
            ]
            setPresets(defaultPresets)
        }
    }

    func soundPreferenceToggleTitle() -> String {
        let isEnabled = UserDefaults.standard.bool(forKey: "SoundsEnabled")
        return isEnabled ? "Disable sound transitions" : "Enable sound transitions"
    }

    func toggleSoundPreference() {
        let currentValue = UserDefaults.standard.bool(forKey: "SoundsEnabled")
        UserDefaults.standard.set(!currentValue, forKey: "SoundsEnabled")
    }

    func getSelectedMonitors() -> Set<String> {
        if let data = UserDefaults.standard.data(forKey: "SelectedMonitors"),
           let monitors = try? JSONDecoder().decode(Set<String>.self, from: data) {
            return monitors
        }
        return Set([NSScreen.main?.localizedName ?? "Main Display"])
    }
    
    func setSelectedMonitors(_ monitors: Set<String>) {
        if let data = try? JSONEncoder().encode(monitors) {
            UserDefaults.standard.set(data, forKey: "SelectedMonitors")
        }
    }

    func getPresets() -> [Preset] {
        if let data = UserDefaults.standard.data(forKey: presetsKey),
           let presets = try? JSONDecoder().decode([Preset].self, from: data) {
            return presets
        }
        return []
    }
    
    func setPresets(_ presets: [Preset]) {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: presetsKey)
        }
    }
    
    func addPreset(_ preset: Preset) {
        var presets = getPresets()
        presets.append(preset)
        setPresets(presets)
    }
    
    func updatePreset(_ preset: Preset) {
        var presets = getPresets()
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index] = preset
            setPresets(presets)
        }
    }
    
    func deletePreset(id: UUID) {
        var presets = getPresets()
        presets.removeAll { $0.id == id }
        setPresets(presets)
    }
}
