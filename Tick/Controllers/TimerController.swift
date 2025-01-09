//
//  TimerController.swift
//  Tick
//
//  Created by Pavel Neizhmak on 01/01/2025.
//

import Foundation
import AppKit

class TimerController {
    private let timerManager: TimerManager
    private let overlayController: TimerOverlayController
    private let soundManager: SoundManager

    private var lastPlayedColor: NSColor?

    init(timerManager: TimerManager, overlayController: TimerOverlayController, soundManager: SoundManager = .shared) {
        self.timerManager = timerManager
        self.overlayController = overlayController
        self.soundManager = soundManager

        setupTimerHandlers()
    }

    private func setupTimerHandlers() {
        timerManager.onTimerUpdate = { [weak self] progress in
            guard let self = self else { return }

            let newColor = self.getProgressColor(for: progress)
            self.overlayController.update(progress: progress, color: newColor)

            if self.lastPlayedColor != newColor {
                self.soundManager.playTransitionSound(for: newColor)
                self.lastPlayedColor = newColor
            }
        }

        timerManager.onTimerComplete = { [weak self] in
            self?.resetTimerUI()
            self?.soundManager.playTimerStoppedSound()
        }
    }

    func startTimer(duration: TimeInterval) {
        if timerManager.isTimerRunning {
            stopTimer()
        }

        timerManager.startTimer(duration: duration)
        overlayController.window?.orderFront(nil)

        let initialProgress = 1.0
        let initialColor = getProgressColor(for: initialProgress)
        overlayController.update(progress: initialProgress, color: initialColor)

        soundManager.playTransitionSound(for: initialColor)
        lastPlayedColor = initialColor
    }

    func stopTimer() {
        timerManager.stopTimer()
        resetTimerUI()
        soundManager.playTimerStoppedSound()
    }
    
    func addTimerUpdateHandler(_ handler: @escaping (Double) -> Void) {
        let originalHandler = self.timerManager.onTimerUpdate
        self.timerManager.onTimerUpdate = { progress in
            originalHandler?(progress)
            handler(progress)
        }
    }
    
    private func resetTimerUI() {
        overlayController.update(progress: 0.0, color: .systemBlue)
        overlayController.window?.orderOut(nil)
        lastPlayedColor = nil
    }

    private func getProgressColor(for progress: Double) -> NSColor {
        switch progress {
        case let p where p > 0.5:
            return .systemGreen
        case let p where p > 0.2:
            return .systemYellow
        default:
            return .systemRed
        }
    }
}
