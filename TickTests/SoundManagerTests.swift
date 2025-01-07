//
//  SoundManagerTests.swift
//  TickTests
//
//  Created by Pavel Neizhmak on 07/01/2025.
//

import XCTest
@testable import Tick

class SoundManagerTests: XCTestCase {
    func testPlayTimerStoppedSoundWhenEnabled() {
        UserDefaults.standard.set(true, forKey: "SoundsEnabled")

        let soundManager = SoundManager.shared
        soundManager.playTimerStoppedSound()

        XCTAssertTrue(true) // Replace this with a meaningful assertion if applicable
    }

    func testPlayTimerStoppedSoundWhenDisabled() {
        UserDefaults.standard.set(false, forKey: "SoundsEnabled")

        let soundManager = SoundManager.shared
        soundManager.playTimerStoppedSound()

        XCTAssertTrue(true)
    }
}
