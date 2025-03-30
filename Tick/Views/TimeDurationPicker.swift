//
//  TimeDurationPicker.swift
//  Tick
//
//  Created by Pavel Neizhmak on 29/03/2025.
//

import SwiftUI

struct TimeDurationPicker: View {
    @Binding var duration: TimeInterval
    
    @State private var hours: Int
    @State private var minutes: Int
    @State private var seconds: Int
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimum = 0
        formatter.maximum = 999
        formatter.allowsFloats = false
        return formatter
    }()
    
    init(duration: Binding<TimeInterval>) {
        self._duration = duration
        let totalSeconds = Int(duration.wrappedValue)
        self._hours = State(initialValue: totalSeconds / 3600)
        self._minutes = State(initialValue: (totalSeconds % 3600) / 60)
        self._seconds = State(initialValue: totalSeconds % 60)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            VStack(alignment: .center, spacing: 4) {
                TextField("", value: $hours, formatter: numberFormatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .onChange(of: hours) { newValue in
                        hours = max(0, min(999, newValue))
                        updateDuration()
                    }
                Text("hours")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(":")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.secondary)
            
            VStack(alignment: .center, spacing: 4) {
                TextField("", value: $minutes, formatter: numberFormatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .onChange(of: minutes) { newValue in
                        minutes = max(0, min(59, newValue))
                        updateDuration()
                    }
                Text("minutes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(":")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.secondary)
            
            VStack(alignment: .center, spacing: 4) {
                TextField("", value: $seconds, formatter: numberFormatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .onChange(of: seconds) { newValue in
                        seconds = max(0, min(59, newValue))
                        updateDuration()
                    }
                Text("seconds")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
    
    private func updateDuration() {
        duration = TimeInterval(max(0, hours * 3600 + minutes * 60 + seconds))
    }
} 
