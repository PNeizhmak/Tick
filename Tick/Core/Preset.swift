//
//  Preset.swift
//  Tick
//
//  Created by Pavel Neizhmak on 29/03/2025.
//

import Foundation

struct Preset: Codable, Identifiable {
    let id: UUID
    var name: String
    var duration: TimeInterval
    
    init(id: UUID = UUID(), name: String, duration: TimeInterval) {
        self.id = id
        self.name = name
        self.duration = duration
    }
} 
