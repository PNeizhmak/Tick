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
            #if DEBUG
            print("Sounds are disabled. No sound will be played.")
            #endif
            return
        }

        let soundName: String = {
            // First, handle the classic hard-coded colors
            switch color {
            case .systemGreen: return "Submarine"
            case .systemYellow: return "Ping"
            case .systemRed: return "Basso"
            default: break
            }

            // Fallback: map to the nearest of the current scheme's buckets (high/mid/low)
            let scheme = PreferencesManager.shared.getColorScheme()
            let high = NSColor.from(scheme.high).usingColorSpace(.sRGB) ?? color
            let mid  = NSColor.from(scheme.mid).usingColorSpace(.sRGB) ?? color
            let low  = NSColor.from(scheme.low).usingColorSpace(.sRGB) ?? color
            let c = color.usingColorSpace(.sRGB) ?? color

            func dist(_ a: NSColor, _ b: NSColor) -> CGFloat {
                let dr = a.redComponent - b.redComponent
                let dg = a.greenComponent - b.greenComponent
                let db = a.blueComponent - b.blueComponent
                return dr*dr + dg*dg + db*db
            }

            let dHigh = dist(c, high)
            let dMid  = dist(c, mid)
            let dLow  = dist(c, low)

            if dHigh <= dMid && dHigh <= dLow { return "Submarine" }
            if dMid <= dHigh && dMid <= dLow { return "Ping" }
            return "Basso"
        }()

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
                #if DEBUG
                print("Playing sound: \(soundName)")
                #endif
                sound.play()
                self.currentlyPlayingSounds[soundName] = sound

                DispatchQueue.global().asyncAfter(deadline: .now() + sound.duration) {
                    self.soundQueue.async { [weak self] in
                        self?.currentlyPlayingSounds.removeValue(forKey: soundName)
                    }
                }
            } else {
                #if DEBUG
                print("Warning: Sound \(soundName) not found!")
                #endif
            }
        }
    }
}
