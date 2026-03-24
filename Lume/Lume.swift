//  Akshay Shukla
//  Lume.swift
//  Lume
//
//  App entry point.
//  - Bridges to AppDelegate for NSWindow management
//  - Declares a MenuBarExtra (the primary UI for control)
//  - Declares a Settings scene for the preferences window
//
//  This is an "agent" app (LSUIElement = true): no Dock icon,
//  interaction is via the menu bar clock icon.
//

import SwiftUI

@main
struct LumeApp: App {
    
    // Bridge to AppKit for window management
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @ObservedObject private var preferences = PreferencesManager.shared
    
    var body: some Scene {
        
        // MARK: - Menu Bar
        MenuBarExtra {
            MenuBarContentView(appDelegate: appDelegate)
        } label: {
            Image(systemName: "clock")
        }
        
        // MARK: - Settings Window
        Settings {
            SettingsView(preferences: preferences)
        }
    }
}

// MARK: - Menu Bar Content

/// The dropdown menu shown when the user clicks the menu bar icon.
struct MenuBarContentView: View {
    
    let appDelegate: AppDelegate
    @ObservedObject private var preferences = PreferencesManager.shared
    
    var body: some View {
        Group {
            // Visibility toggle
            Button {
                withAnimation(.easeInOut(duration: 0.4)) {
                    preferences.toggleVisibility()
                }
            } label: {
                Label(
                    preferences.isVisible ? "Hide Clock" : "Show Clock",
                    systemImage: preferences.isVisible ? "eye.slash" : "eye"
                )
            }
            .keyboardShortcut("w", modifiers: [.command, .shift])
            
            Divider()
            
            // Reposition mode
            Button {
                appDelegate.toggleRepositioning()
            } label: {
                Label(
                    appDelegate.isRepositioning ? "Done Repositioning" : "Reposition Clock",
                    systemImage: "arrow.up.and.down.and.arrow.left.and.right"
                )
            }
            .keyboardShortcut("r", modifiers: [.command])
            
            // Reset position
            Button {
                preferences.resetPosition()
            } label: {
                Label("Reset Position", systemImage: "arrow.counterclockwise")
            }
            
            Divider()
            
            // Quick toggles
            Toggle(isOn: $preferences.use24HourFormat) {
                Label("24-Hour Format", systemImage: "clock.badge.checkmark")
            }
            
            Toggle(isOn: $preferences.showDate) {
                Label("Show Date", systemImage: "calendar")
            }
            
            Divider()
            
            // Settings
            SettingsLink {
                Label("Settings…", systemImage: "gear")
            }
            .keyboardShortcut(",", modifiers: [.command])
            
            Divider()
            
            // Quit
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit Lume", systemImage: "power")
            }
            .keyboardShortcut("q", modifiers: [.command])
        }
    }
}
