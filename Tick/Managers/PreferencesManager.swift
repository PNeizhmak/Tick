//
//  PreferencesManager.swift
//  Tick
//
//  Created by Pavel Neizhmak on 07/01/2025.
//

import Foundation

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
}

