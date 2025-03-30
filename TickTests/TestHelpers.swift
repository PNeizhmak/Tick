//
//  TestHelpers.swift
//  TickTests
//
//  Created by Pavel Neizhmak on 04/01/2025.
//

import Foundation
@testable import Tick

extension PreferencesManager {
    static func resetForTesting() {
        UserDefaults.standard.removeObject(forKey: "TimerPresets")
        UserDefaults.standard.removeObject(forKey: "SelectedMonitors")
        UserDefaults.standard.removeObject(forKey: "SoundsEnabled")
    }
}

extension Preset {
    static func mock(name: String = "Test Preset", duration: TimeInterval = 300) -> Preset {
        return Preset(name: name, duration: duration)
    }
} 
