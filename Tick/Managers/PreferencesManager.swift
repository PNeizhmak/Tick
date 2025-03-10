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

    private init() {}

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
}
