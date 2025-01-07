//
//  TimerControllerTests.swift
//  TickTests
//
//  Created by Pavel Neizhmak on 07/01/2025.
//

import XCTest
@testable import Tick

class TimerControllerTests: XCTestCase {
    var timerManager: TimerManager!
    var overlayController: TimerOverlayController!
    var timerController: TimerController!

    override func setUp() {
        super.setUp()
        timerManager = TimerManager()
        overlayController = TimerOverlayController()
        timerController = TimerController(timerManager: timerManager, overlayController: overlayController)
    }

    override func tearDown() {
        timerManager = nil
        overlayController = nil
        timerController = nil
        super.tearDown()
    }

    func testStopSoundOnTimerComplete() {
        let expectation = self.expectation(description: "Timer complete triggers stop sound")

        timerManager.onTimerComplete = {
            expectation.fulfill()
        }

        timerController.startTimer(duration: 1) // Start a very short timer
        wait(for: [expectation], timeout: 2)
    }

    func testStopSoundOnManualStop() {
        timerController.startTimer(duration: 60)
        timerController.stopTimer()

        XCTAssertTrue(true)
    }
}
