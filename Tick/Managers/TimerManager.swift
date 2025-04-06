//
//  TimerManager.swift
//  Tick
//
//  Created by Pavel Neizhmak on 01/01/2025.
//

import Foundation

class TimerManager: ObservableObject {
    enum Notifications {
        static let startTimer = Notification.Name("com.tick.timer.start")
    }
    
    @Published var remainingTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    private var timer: Timer?
    private var startTime: Date?
    private var endTime: Date?
    private var isCompleted: Bool = false
    private var isPaused: Bool = false
    private var pauseTime: Date?
    
    var onTimerUpdate: ((Double) -> Void)?
    var onTimerComplete: (() -> Void)?
    var onTimerStop: (() -> Void)?
    
    var isTimerRunning: Bool {
        return remainingTime > 0 && timer != nil && !isPaused
    }
    
    var isTimerPaused: Bool {
        return isPaused
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


    func stopTimer(suppressStopSound: Bool = false) {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
        remainingTime = 0
        totalTime = 0
        startTime = nil
        endTime = nil

        if !isCompleted {
            isCompleted = true
            onTimerUpdate?(0.0)
            onTimerComplete?()

            if !suppressStopSound {
                onTimerStop?()
            }
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

    func pauseTimer() {
        guard timer != nil && !isPaused && remainingTime > 0 else { return }
        isPaused = true
        pauseTime = Date()
        timer?.invalidate()
        timer = nil
    }
    
    func resumeTimer() {
        guard isPaused && remainingTime > 0 else { return }
        isPaused = false
        
        if let pauseTime = pauseTime, let endTime = endTime {
            let timePaused = Date().timeIntervalSince(pauseTime)
            self.endTime = endTime.addingTimeInterval(timePaused)
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
        self.pauseTime = nil
    }
}
