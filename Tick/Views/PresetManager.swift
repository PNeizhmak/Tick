//
//  PresetManager.swift
//  Tick
//
//  Created by Pavel Neizhmak on 29/03/2025.
//

import SwiftUI

struct PresetManager: View {
    @State private var presets: [Preset] = PreferencesManager.shared.getPresets()
    @State private var showingAddPreset = false
    @State private var newPresetName = ""
    @State private var newPresetDuration: TimeInterval = 25 * 60
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Timer Presets")
                .font(.system(size: 24, weight: .medium))
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color(.windowBackgroundColor))
            
            List {
                ForEach(presets) { preset in
                    PresetRow(preset: preset,
                            onUpdate: { updatedPreset in
                        if let index = presets.firstIndex(where: { $0.id == updatedPreset.id }) {
                            presets[index] = updatedPreset
                            PreferencesManager.shared.updatePreset(updatedPreset)
                            NotificationCenter.default.post(name: PreferencesManager.Notifications.presetsDidChange, object: nil)
                        }
                    },
                            onDelete: {
                        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
                            PreferencesManager.shared.deletePreset(id: preset.id)
                            presets.remove(at: index)
                            NotificationCenter.default.post(name: PreferencesManager.Notifications.presetsDidChange, object: nil)
                        }
                    })
                }
            }
            .listStyle(InsetListStyle())
            
            Divider()
            
            HStack {
                Spacer()
                
                Button(action: {
                    showingAddPreset = true
                    newPresetName = ""
                    newPresetDuration = 25 * 60
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add New Preset")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(.windowBackgroundColor))
        }
        .frame(width: 400, height: 500)
        .sheet(isPresented: $showingAddPreset) {
            AddPresetView(isPresented: $showingAddPreset) { name, duration in
                print("PresetManager: Adding new preset: \(name)")
                let newPreset = Preset(name: name, duration: duration)
                PreferencesManager.shared.addPreset(newPreset)
                presets = PreferencesManager.shared.getPresets()
                print("PresetManager: Posting presetsDidChange notification")
                NotificationCenter.default.post(name: PreferencesManager.Notifications.presetsDidChange, object: nil)
            }
        }
    }
}

struct PresetRow: View {
    let preset: Preset
    let onUpdate: (Preset) -> Void
    let onDelete: () -> Void
    @State private var isEditing = false
    @State private var editedName: String
    @State private var editedDuration: TimeInterval
    
    init(preset: Preset, onUpdate: @escaping (Preset) -> Void, onDelete: @escaping () -> Void) {
        self.preset = preset
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _editedName = State(initialValue: preset.name)
        _editedDuration = State(initialValue: preset.duration)
    }
    
    var body: some View {
        if isEditing {
            VStack(spacing: 12) {
                TextField("Preset Name", text: $editedName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                DurationPicker(duration: $editedDuration)
                
                HStack {
                    Spacer()
                    Button("Cancel") {
                        editedName = preset.name
                        editedDuration = preset.duration
                        isEditing = false
                    }
                    .buttonStyle(.borderless)
                    
                    Button("Save") {
                        let updatedPreset = Preset(id: preset.id, name: editedName, duration: editedDuration)
                        onUpdate(updatedPreset)
                        isEditing = false
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.vertical, 8)
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.headline)
                    Text(formatDuration(preset.duration))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    isEditing = true
                } label: {
                    Text("Edit")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderless)
                
                Button {
                    onDelete()
                } label: {
                    Text("Delete")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) minutes"
    }
}

struct AddPresetView: View {
    @Binding var isPresented: Bool
    let onAdd: (String, TimeInterval) -> Void
    
    @State private var name = ""
    @State private var duration: TimeInterval = 25 * 60
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Add New Preset")
                .font(.title2)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 16) {
                TextField("Preset Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TimeDurationPicker(duration: $duration)
            }
            .padding(.horizontal)
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button("Add") {
                    onAdd(name, duration)
                    isPresented = false
                }
                .buttonStyle(.bordered)
                .disabled(name.isEmpty)
            }
            .padding()
            .background(Color(.windowBackgroundColor))
        }
        .frame(width: 300, height: 250)
    }
} 
