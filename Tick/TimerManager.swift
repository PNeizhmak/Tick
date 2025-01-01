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

    var onTimerUpdate: ((Double) -> Void)?
    var onTimerComplete: (() -> Void)?

    func startTimer(duration: TimeInterval) {
        totalTime = duration
        remainingTime = duration

        timer?.invalidate() // Stop any existing timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        remainingTime = 0
        totalTime = 0
        onTimerComplete?()
    }

    @objc private func updateTimer() {
        guard remainingTime > 0 else {
            stopTimer()
            return
        }

        remainingTime -= 1
        let progress = remainingTime / totalTime
        onTimerUpdate?(progress)
    }
}
