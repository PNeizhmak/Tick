//
//  SoundManager.swift
//  Tick
//
//  Created by Pavel Neizhmak on 04/01/2025.
//

import Cocoa

class SoundManager {
    static let shared = SoundManager()

    private init() {}

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

        guard let sound = NSSound(named: soundName) else {
            print("Sound \(soundName) not found! Defaulting to system beep.")
            NSSound.beep()
            return
        }

        sound.stop()
        sound.play()
    }
}
