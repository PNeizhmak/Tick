//
//  DurationPicker.swift
//  Tick
//
//  Created by Pavel Neizhmak on 29/03/2025.
//

import SwiftUI

struct DurationPicker: View {
    @Binding var duration: TimeInterval
    
    var body: some View {
        Picker("Duration", selection: $duration) {
            ForEach([1, 5, 10, 15, 20, 25, 30, 45, 60], id: \.self) { minutes in
                Text("\(minutes) min").tag(TimeInterval(minutes * 60))
            }
        }
        .pickerStyle(.menu)
    }
} 
