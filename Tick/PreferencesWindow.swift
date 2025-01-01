//
//  PreferencesWindow.swift
//  Tick
//
//  Created by Pavel Neizhmak on 01/01/2025.
//

import SwiftUI

struct PreferencesWindow: View {
    @State private var customTime: String = "300" // Default to 300 seconds (5 minutes)

    var onSave: ((TimeInterval) -> Void)? // Callback for saving the timer duration

    var body: some View {
        VStack {
            Text("Set Timer Duration")
                .font(.headline)
                .padding()

            TextField("Enter time in seconds", text: $customTime)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
                .onChange(of: customTime) { newValue, _ in
                    customTime = newValue.filter { "0123456789".contains($0) }
                }

            Button("Save") {
                if let duration = TimeInterval(customTime), duration > 0 {
                    onSave?(duration)
                } else {
                    print("Invalid duration entered")
                }
            }
            .padding()
        }
        .frame(width: 300, height: 150)
    }
}

