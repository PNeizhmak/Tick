//
//  TickApp.swift
//  Tick
//
//  Created by Pavel Neizhmak on 01/01/2025.
//

import SwiftUI
import AppKit

@main
struct TickApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No main window, so we leave this empty
        Settings {
            EmptyView() // Optionally, for macOS app preferences
        }
    }
}
