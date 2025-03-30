//
//  SetTimerWindow.swift
//  Tick
//
//  Created by Pavel Neizhmak on 29/03/2025.
//

import AppKit
import SwiftUI

class SetTimerWindow: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    
    func show() {
        if let existingWindow = window {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let contentView = SetTimerView(isPresented: .constant(true)) { [weak self] duration in
            // Start the timer
            NotificationCenter.default.post(
                name: TimerManager.Notifications.startTimer,
                object: nil,
                userInfo: ["duration": duration]
            )
            self?.window?.close()
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 250),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Set Timer Duration"
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
