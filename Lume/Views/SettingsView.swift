//  Akshay Shukla
//  SettingsView.swift
//  Lume
//
//  Tabbed settings window — Display, Appearance, Themes, Behavior.
//  Native macOS tab bar style using TabView(.tabBarOnly) approach.
//

import SwiftUI

struct SettingsView: View {

    @State private var preferences = PreferencesManager.shared
    @State private var selectedTab  = SettingsTab.display

    enum SettingsTab: String, CaseIterable {
        case display    = "Display"
        case appearance = "Appearance"
        case themes     = "Themes"
        case behavior   = "Behavior"

        var icon: String {
            switch self {
            case .display:    return "clock"
            case .appearance: return "paintbrush"
            case .themes:     return "sparkles"
            case .behavior:   return "gear"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            displayTab.tabItem { Label("Display",    systemImage: "clock") }
                .tag(SettingsTab.display)
            appearanceTab.tabItem { Label("Appearance", systemImage: "paintbrush") }
                .tag(SettingsTab.appearance)
            ThemePickerView().tabItem { Label("Themes", systemImage: "sparkles") }
                .tag(SettingsTab.themes)
            behaviorTab.tabItem { Label("Behavior",  systemImage: "gear") }
                .tag(SettingsTab.behavior)
        }
        .frame(width: 520, height: 480)
    }

    // MARK: - Display Tab

    private var displayTab: some View {
        Form {
            Section {
                Toggle("Use 24-hour format", isOn: $preferences.use24HourFormat)
                Toggle("Show date", isOn: $preferences.showDate)
            } header: {
                Label("Time & Date", systemImage: "clock")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - Appearance Tab

    private var appearanceTab: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Opacity")
                        Spacer()
                        Text("\(Int(preferences.clockOpacity * 100))%")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $preferences.clockOpacity, in: 0.2...1.0, step: 0.05)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Clock size")
                        Spacer()
                        Text("\(Int(preferences.fontSize)) pt")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $preferences.fontSize, in: 32...160, step: 2)
                }
            } header: {
                Label("Clock Appearance", systemImage: "paintbrush")
            }

            Section {
                // Accent color picker (feeds into ThemeEngine)
                ColorPicker("Accent color", selection: accentColorBinding)

                Button("Reset to Defaults") {
                    ThemeEngine.shared.themePreferences = .init()
                    preferences.clockOpacity = 0.80
                    preferences.fontSize = 72
                }
                .foregroundStyle(.red)
            } header: {
                Label("Colors", systemImage: "paintpalette")
            }

            Section {
                Button("Reset Clock Position") {
                    preferences.resetPosition()
                }
            } header: {
                Label("Position", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - Behavior Tab

    private var behaviorTab: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $preferences.launchAtLogin)
            } header: {
                Label("Startup", systemImage: "power")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - Helpers

    private var accentColorBinding: Binding<Color> {
        Binding(
            get: { ThemeEngine.shared.themePreferences.accentColor },
            set: { ThemeEngine.shared.themePreferences.accentColor = $0 }
        )
    }
}
