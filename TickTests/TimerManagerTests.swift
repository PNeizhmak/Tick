//
//  TimerManagerTests.swift
//  TickTests
//
//  Created by Pavel Neizhmak on 02/01/2025.
//

import XCTest
@testable import Tick

class TimerManagerTests: XCTestCase {
    var timerManager: TimerManager!

    override func setUp() {
        super.setUp()
        timerManager = TimerManager()
    }

    override func tearDown() {
        timerManager = nil
        super.tearDown()
    }

    func testStartTimerResetsPreviousTimer() {
        let firstDuration: TimeInterval = 60
        let secondDuration: TimeInterval = 30

        timerManager.startTimer(duration: firstDuration)
        timerManager.startTimer(duration: secondDuration)

        XCTAssertEqual(timerManager.totalTime, secondDuration)
        XCTAssertEqual(timerManager.remainingTime, secondDuration)
        XCTAssertTrue(timerManager.isTimerRunning)
    }

    func testStopTimerWithSuppression() {
        timerManager.startTimer(duration: 60)
        timerManager.stopTimer(suppressStopSound: true)

        XCTAssertEqual(timerManager.remainingTime, 0)
        XCTAssertEqual(timerManager.totalTime, 0)
        XCTAssertFalse(timerManager.isTimerRunning)
    }

    func testStopTimerWithoutSuppression() {
        timerManager.startTimer(duration: 60)
        timerManager.stopTimer(suppressStopSound: false)

        XCTAssertEqual(timerManager.remainingTime, 0)
        XCTAssertEqual(timerManager.totalTime, 0)
        XCTAssertFalse(timerManager.isTimerRunning)
    }

    func testTimerCompletionCallsOnComplete() {
        let expectation = self.expectation(description: "Timer completes")
        let duration: TimeInterval = 1

        timerManager.onTimerComplete = {
            expectation.fulfill()
        }

        timerManager.startTimer(duration: duration)
        wait(for: [expectation], timeout: duration + 2)

        XCTAssertFalse(timerManager.isTimerRunning)
    }
}
