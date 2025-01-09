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

    func testStopTimerWithSoundSuppression() {
        timerController.startTimer(duration: 60)
        timerController.stopTimer(suppressStopSound: true)

        XCTAssertFalse(timerManager.isTimerRunning)
        XCTAssertEqual(timerManager.remainingTime, 0)
    }

    func testStopTimerWithoutSoundSuppression() {
        timerController.startTimer(duration: 60)
        timerController.stopTimer(suppressStopSound: false)

        XCTAssertFalse(timerManager.isTimerRunning)
        XCTAssertEqual(timerManager.remainingTime, 0)
    }

    func testStopSoundOnTimerComplete() {
        let expectation = self.expectation(description: "Timer complete triggers stop sound")
        timerManager.onTimerComplete = {
            expectation.fulfill()
        }

        timerController.startTimer(duration: 1)
        wait(for: [expectation], timeout: 2)
    }
}
