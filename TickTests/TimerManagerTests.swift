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

    func testStartTimer() {
        let duration: TimeInterval = 60
        timerManager.startTimer(duration: duration)
        
        XCTAssertEqual(timerManager.totalTime, duration)
        XCTAssertEqual(timerManager.remainingTime, duration)
    }

    func testTimerProgress() {
        let expectation = self.expectation(description: "Timer progress updates")
        let duration: TimeInterval = 10
        var progressUpdates: [Double] = []

        timerManager.onTimerUpdate = { progress in
            progressUpdates.append(progress)
            if progress == 0.0 {
                expectation.fulfill()
            }
        }

        timerManager.startTimer(duration: duration)

        wait(for: [expectation], timeout: duration + 2)

        guard let firstProgress = progressUpdates.first,
              let lastProgress = progressUpdates.last else {
            XCTFail("Progress updates are empty or nil")
            return
        }

        XCTAssertEqual(firstProgress, 1.0, accuracy: 0.1)
        XCTAssertEqual(lastProgress, 0.0, accuracy: 0.1)

        XCTAssertEqual(progressUpdates.count, Int(duration) + 1, accuracy: 1)
    }


    func testStopTimer() {
        let duration: TimeInterval = 60
        timerManager.startTimer(duration: duration)
        timerManager.stopTimer()

        XCTAssertEqual(timerManager.remainingTime, 0)
        XCTAssertEqual(timerManager.totalTime, 0)
    }

    func testTimerCompletion() {
        let expectation = self.expectation(description: "Timer completes")
        let duration: TimeInterval = 1

        timerManager.onTimerComplete = {
            expectation.fulfill()
        }

        timerManager.startTimer(duration: duration)
        wait(for: [expectation], timeout: duration + 2)

        XCTAssertEqual(timerManager.remainingTime, 0)
    }

    func testProgressCallbackFrequency() {
        let expectation = self.expectation(description: "Timer progress callback frequency")
        let duration: TimeInterval = 5
        var progressUpdateCount = 0

        timerManager.onTimerUpdate = { _ in
            progressUpdateCount += 1
        }

        timerManager.onTimerComplete = {
            expectation.fulfill()
        }

        timerManager.startTimer(duration: duration)
        wait(for: [expectation], timeout: duration + 2)

        XCTAssertGreaterThanOrEqual(progressUpdateCount, Int(duration))
    }
}
