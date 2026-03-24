//  Akshay Shukla
//  SettingsView.swift
//  Lume
//
//  Preferences panel accessible from the menu bar.
//  Native macOS Form layout with clean sections.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var preferences = PreferencesManager.shared
    
    var body: some View {
        Form {
            // MARK: - Display Section
            Section {
                Toggle("Use 24-hour format", isOn: $preferences.use24HourFormat)
                Toggle("Show date", isOn: $preferences.showDate)
            } header: {
                Label("Display", systemImage: "clock")
            }
            
            // MARK: - Appearance Section
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Opacity: \(Int(preferences.clockOpacity * 100))%")
                        .font(.callout)
                    Slider(
                        value: $preferences.clockOpacity,
                        in: AppConstants.Limits.minOpacity...AppConstants.Limits.maxOpacity,
                        step: 0.05
                    )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Font size: \(Int(preferences.fontSize)) pt")
                        .font(.callout)
                    Slider(
                        value: $preferences.fontSize,
                        in: AppConstants.Limits.minFontSize...AppConstants.Limits.maxFontSize,
                        step: 2
                    )
                }
            } header: {
                Label("Appearance", systemImage: "paintbrush")
            }
            
            // MARK: - Position Section
            Section {
                Button("Reset to Center") {
                    preferences.resetPosition()
                }
            } header: {
                Label("Position", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
            }
            
            // MARK: - Behavior Section
            Section {
                Toggle("Launch at login", isOn: $preferences.launchAtLogin)
            } header: {
                Label("Behavior", systemImage: "gear")
            }
        }
        .formStyle(.grouped)
        .frame(width: 380, height: 420)
    }
}
