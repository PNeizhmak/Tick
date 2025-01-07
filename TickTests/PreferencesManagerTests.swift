//
//  PreferencesManagerTests.swift
//  TickTests
//
//  Created by Pavel Neizhmak on 07/01/2025.
//

import XCTest
@testable import Tick

class PreferencesManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "SoundsEnabled")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "SoundsEnabled")
        super.tearDown()
    }

    func testSoundPreferenceToggle() {
        let preferencesManager = PreferencesManager.shared

        UserDefaults.standard.set(true, forKey: "SoundsEnabled")
        XCTAssertEqual(preferencesManager.soundPreferenceToggleTitle(), "Disable sound transitions")

        preferencesManager.toggleSoundPreference()
        XCTAssertEqual(preferencesManager.soundPreferenceToggleTitle(), "Enable sound transitions")

        preferencesManager.toggleSoundPreference()
        XCTAssertEqual(preferencesManager.soundPreferenceToggleTitle(), "Disable sound transitions")
    }
}
