//
//  TimerManager.swift
//  Tick
//
//  Created by Pavel Neizhmak on 01/01/2025.
//

import Foundation

class TimerManager: ObservableObject {
    @Published var remainingTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    private var timer: Timer?
    private var startTime: Date?
    private var endTime: Date?
    private var isCompleted: Bool = false
    
    var onTimerUpdate: ((Double) -> Void)?
    var onTimerComplete: (() -> Void)?

    var isTimerRunning: Bool {
        return remainingTime > 0 && timer != nil
    }

    func startTimer(duration: TimeInterval) {
        stopTimer()

        isCompleted = false
        totalTime = duration
        remainingTime = duration

        onTimerUpdate?(1.0)

        startTime = Date()
        endTime = Date().addingTimeInterval(duration)

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }


    func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate() // Stop the Timer
        timer = nil
        remainingTime = 0
        totalTime = 0
        startTime = nil
        endTime = nil

        if !isCompleted {
            isCompleted = true
            onTimerUpdate?(0.0)
            onTimerComplete?()
        }
    }

    @objc private func updateTimer() {
        guard let endTime = endTime else { return }

        let now = Date()
        remainingTime = max(0, endTime.timeIntervalSince(now))

        if remainingTime <= 0 {
            stopTimer()
            return
        }

        let progress = remainingTime / totalTime
        onTimerUpdate?(progress)
    }
}
