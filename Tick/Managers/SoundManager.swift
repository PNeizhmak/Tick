//
//  SoundManager.swift
//  Tick
//
//  Created by Pavel Neizhmak on 04/01/2025.
//

import Cocoa

class SoundManager {
    static let shared = SoundManager()

    private var currentlyPlayingSounds: [String: NSSound] = [:]
    private let soundQueue = DispatchQueue(label: "com.tick.soundManagerQueue")
    private var suppressStopSoundGlobally = false

    private init() {}

    func suppressStopSoundGlobally(_ suppress: Bool) {
        soundQueue.async {
            self.suppressStopSoundGlobally = suppress
        }
    }

    func playTransitionSound(for color: NSColor) {
        guard UserDefaults.standard.bool(forKey: "SoundsEnabled") else {
            print("Sounds are disabled. No sound will be played.")
            return
        }

        let soundName: String
        switch color {
        case .systemGreen:
            soundName = "Submarine"
        case .systemYellow:
            soundName = "Ping"
        case .systemRed:
            soundName = "Basso"
        default:
            return
        }

        playSound(named: soundName)
    }

    func playTimerStoppedSound() {
        soundQueue.async { [weak self] in
            guard let self = self else { return }

            if self.suppressStopSoundGlobally {
                return
            }

            guard UserDefaults.standard.bool(forKey: "SoundsEnabled") else {
                return
            }

            self.playSound(named: "Pop")
        }
    }

    func playTimerPausedSound() {
        soundQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard UserDefaults.standard.bool(forKey: "SoundsEnabled") else {
                return
            }
            
            self.playSound(named: "Tink")
        }
    }

    func playTimerResumedSound() {
        soundQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard UserDefaults.standard.bool(forKey: "SoundsEnabled") else {
                return
            }
            
            self.playSound(named: "Blow")
        }
    }

    private func playSound(named soundName: String) {
        soundQueue.async { [weak self] in
            guard let self = self else { return }

            if let existingSound = self.currentlyPlayingSounds[soundName], existingSound.isPlaying {
                return
            }

            if let sound = NSSound(named: soundName) {
                print("Playing sound: \(soundName)")
                sound.play()
                self.currentlyPlayingSounds[soundName] = sound

                DispatchQueue.global().asyncAfter(deadline: .now() + sound.duration) {
                    self.soundQueue.async { [weak self] in
                        self?.currentlyPlayingSounds.removeValue(forKey: soundName)
                    }
                }
            } else {
                print("Warning: Sound \(soundName) not found!")
            }
        }
    }
}
