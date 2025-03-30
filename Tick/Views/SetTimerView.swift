//
//  SetTimerView.swift
//  Tick
//
//  Created by Pavel Neizhmak on 29/03/2025.
//

import SwiftUI

struct SetTimerView: View {
    @Binding var isPresented: Bool
    let onSetTimer: (TimeInterval) -> Void
    
    @State private var duration: TimeInterval = 30// Default
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Custom Duration")
                .font(.system(size: 24, weight: .medium))
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color(.windowBackgroundColor))
            
            List {
                TimeDurationPicker(duration: $duration)
                    .listRowInsets(EdgeInsets())
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
            }
            .listStyle(InsetListStyle())
            
            Divider()
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button("Start Timer") {
                    onSetTimer(duration)
                    isPresented = false
                }
                .buttonStyle(.bordered)
                .disabled(duration == 0)
            }
            .padding()
            .background(Color(.windowBackgroundColor))
        }
        .frame(width: 400, height: 250)
    }
} 
