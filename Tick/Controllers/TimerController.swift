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
    private var isStoppingTimer = false

    init(timerManager: TimerManager, overlayController: TimerOverlayController, soundManager: SoundManager = .shared) {
        self.timerManager = timerManager
        self.overlayController = overlayController
        self.soundManager = soundManager

        setupTimerHandlers()
    }

    private func setupTimerHandlers() {
        timerManager.onTimerUpdate = { [weak self] progress in
            guard let self = self else { return }

            if self.isStoppingTimer {
                return
            }

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

        timerManager.onTimerStop = { [weak self] in
            self?.soundManager.playTimerStoppedSound()
        }
    }

    func startTimer(duration: TimeInterval) {
        if timerManager.isTimerRunning {
            SoundManager.shared.suppressStopSoundGlobally(true)
            stopTimer(suppressStopSound: true)
            SoundManager.shared.suppressStopSoundGlobally(false)
        }
        
        // small delay to separate stop and start logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("Starting new timer with duration: \(duration) seconds.")
            self.timerManager.startTimer(duration: duration)
            self.overlayController.window?.orderFront(nil)

            let initialProgress = 1.0
            let initialColor = self.getProgressColor(for: initialProgress)
            self.overlayController.update(progress: initialProgress, color: initialColor)

            print("Playing transition sound (Submarine).")
            self.soundManager.playTransitionSound(for: initialColor)
            self.lastPlayedColor = initialColor
        }
    }

    private func startNewTimer(duration: TimeInterval) {
        timerManager.startTimer(duration: duration)
        overlayController.window?.orderFront(nil)

        let initialProgress = 1.0
        let initialColor = getProgressColor(for: initialProgress)
        overlayController.update(progress: initialProgress, color: initialColor)

        soundManager.playTransitionSound(for: initialColor)
        lastPlayedColor = initialColor
    }

    func stopTimer(suppressStopSound: Bool = false) {
        isStoppingTimer = true
        timerManager.stopTimer(suppressStopSound: suppressStopSound)
        resetTimerUI()

        if !suppressStopSound {
            soundManager.playTimerStoppedSound()
        }

        isStoppingTimer = false
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
