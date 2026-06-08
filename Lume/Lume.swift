//  Akshay Shukla
//  Lume.swift
//  Lume
//
//  App entry point — bridges to AppDelegate for NSWindow management,
//  declares the MenuBarExtra and Settings scene.
//  Singletons (ThemeEngine, PreferencesManager) are accessed directly
//  since @Observable doesn't need environment injection for non-view access.
//

import SwiftUI

@main
struct LumeApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {

        // MARK: - Menu Bar
        MenuBarExtra {
            MenuBarContentView(appDelegate: appDelegate)
        } label: {
            MenuBarLabel()
        }

        // MARK: - Settings Window
        Settings {
            SettingsView()
        }
    }
}

// MARK: - Menu Bar Label

/// Dynamic label showing a live clock icon.
struct MenuBarLabel: View {
    var body: some View {
        Image(systemName: "clock")
    }
}

// MARK: - Menu Bar Content

struct MenuBarContentView: View {

    let appDelegate: AppDelegate

    @State private var preferences = PreferencesManager.shared
    @State private var engine = ThemeEngine.shared

    var body: some View {
        Group {

            // Current time readout
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.secondary)
                Text(currentTimeString)
                    .font(.system(.body, design: .monospaced))
                    .monospacedDigit()
            }
            .padding(.vertical, 4)

            Divider()

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

            // Reposition mode
            Button { appDelegate.toggleRepositioning() } label: {
                Label(
                    appDelegate.isRepositioning ? "Done Repositioning" : "Reposition Clock",
                    systemImage: "arrow.up.and.down.and.arrow.left.and.right"
                )
            }
            .keyboardShortcut("r", modifiers: [.command])

            Button { preferences.resetPosition() } label: {
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

            // Active theme indicator
            Menu {
                ForEach(ClockThemeID.allCases) { id in
                    Button {
                        engine.selectTheme(id)
                    } label: {
                        HStack {
                            Text(id.displayName)
                            if engine.activeThemeID == id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Label("Theme: \(engine.activeThemeID.displayName)", systemImage: "paintbrush")
            }

            Divider()

            SettingsLink {
                Label("Settings…", systemImage: "gear")
            }
            .keyboardShortcut(",", modifiers: [.command])

            Divider()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit Lume", systemImage: "power")
            }
            .keyboardShortcut("q", modifiers: [.command])
        }
    }

    private var currentTimeString: String {
        let f = DateFormatter()
        f.dateFormat = preferences.use24HourFormat ? "HH:mm:ss" : "h:mm:ss a"
        return f.string(from: Date())
    }
}
