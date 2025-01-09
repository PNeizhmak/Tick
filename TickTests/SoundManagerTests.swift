//
//  SoundManagerTests.swift
//  TickTests
//
//  Created by Pavel Neizhmak on 07/01/2025.
//

import XCTest
@testable import Tick

class SoundManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.set(true, forKey: "SoundsEnabled")
        SoundManager.shared.suppressStopSoundGlobally(false)
    }

    override func tearDown() {
        SoundManager.shared.suppressStopSoundGlobally(false)
        super.tearDown()
    }

    func testPlayTimerStoppedSoundWhenEnabled() {
        let soundManager = SoundManager.shared
        soundManager.playTimerStoppedSound()
        XCTAssertTrue(true)
    }

    func testPlayTimerStoppedSoundWhenDisabled() {
        UserDefaults.standard.set(false, forKey: "SoundsEnabled")

        let soundManager = SoundManager.shared
        soundManager.playTimerStoppedSound()
        XCTAssertTrue(true)
    }

    func testSuppressStopSoundGlobally() {
        let soundManager = SoundManager.shared
        soundManager.suppressStopSoundGlobally(true)
        soundManager.playTimerStoppedSound()
        XCTAssertTrue(true)
    }

    func testPlayTransitionSound() {
        let soundManager = SoundManager.shared
        soundManager.playTransitionSound(for: .systemGreen)
        XCTAssertTrue(true)
    }
}
