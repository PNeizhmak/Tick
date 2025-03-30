//
//  PresetManagerWindow.swift
//  Tick
//
//  Created by Pavel Neizhmak on 29/03/2025.
//

import AppKit
import SwiftUI

class PresetManagerWindow: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    
    func show() {
        if let existingWindow = window {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let contentView = PresetManager()
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Timer Presets"
        window.contentView = NSHostingView(rootView: contentView)
        window.center()
        window.delegate = self
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        self.window = window
    }
    
    func windowWillClose(_ notification: Notification) {
        window = nil
    }
} 
