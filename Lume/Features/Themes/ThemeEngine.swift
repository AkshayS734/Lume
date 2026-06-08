//  Akshay Shukla
//  ThemeEngine.swift
//  Lume
//
//  Observable singleton that manages the active theme, live-preview state,
//  and per-theme appearance preferences.
//  Uses @Observable (macOS 14 Sonoma) for granular, efficient updates.
//

import SwiftUI
import Observation

// MARK: - ThemeEngine

@Observable
@MainActor
final class ThemeEngine {

    // MARK: - Singleton
    static let shared = ThemeEngine()

    // MARK: - Active theme

    /// The user's persisted theme choice.
    var activeThemeID: ClockThemeID = .minimalDigital {
        didSet {
            UserDefaults.standard.set(activeThemeID.rawValue, forKey: Keys.activeThemeID)
        }
    }

    /// Non-nil while the user is hovering a theme in the picker (live preview).
    /// Cleared automatically when hover ends.
    var previewThemeID: ClockThemeID? = nil

    /// The theme actually rendered — preview takes priority over active.
    var effectiveThemeID: ClockThemeID {
        previewThemeID ?? activeThemeID
    }

    var effectiveTheme: AnyClockTheme {
        ThemeRegistry.theme(for: effectiveThemeID)
    }

    // MARK: - Appearance overrides

    /// User-configured appearance overrides (persisted as JSON).
    var themePreferences = ThemePreferences() {
        didSet { savePreferences() }
    }

    // MARK: - All themes (for picker)

    var allThemes: [AnyClockTheme] {
        ThemeRegistry.all
    }

    var themesByCategory: [ThemeCategory: [AnyClockTheme]] {
        Dictionary(grouping: allThemes) { $0.category }
    }

    // MARK: - Init

    private init() {
        // Restore persisted active theme
        if let raw = UserDefaults.standard.string(forKey: Keys.activeThemeID),
           let id = ClockThemeID(rawValue: raw) {
            activeThemeID = id
        }
        // Restore persisted theme preferences
        loadPreferences()
    }

    // MARK: - Preview helpers

    /// Set during Settings hover; cleared when hover ends.
    func beginPreview(of themeID: ClockThemeID) {
        previewThemeID = themeID
    }

    func endPreview() {
        previewThemeID = nil
    }

    /// Activate a theme (called on picker tap/click).
    func selectTheme(_ id: ClockThemeID) {
        activeThemeID = id
        previewThemeID = nil
    }

    // MARK: - Persistence

    private func savePreferences() {
        guard let data = try? JSONEncoder().encode(PreferencesCodable(from: themePreferences)) else { return }
        UserDefaults.standard.set(data, forKey: Keys.themePreferences)
    }

    private func loadPreferences() {
        guard let data = UserDefaults.standard.data(forKey: Keys.themePreferences),
              let decoded = try? JSONDecoder().decode(PreferencesCodable.self, from: data) else { return }
        themePreferences = decoded.toThemePreferences()
    }

    // MARK: - Keys

    private enum Keys {
        static let activeThemeID    = "lumeActiveThemeID"
        static let themePreferences = "lumeThemePreferences"
    }
}

// MARK: - Codable bridge for ThemePreferences

/// ThemePreferences uses Color which isn't Codable — bridge via hex strings.
private struct PreferencesCodable: Codable {
    var accentColorHex: String
    var secondaryColorHex: String
    var fontOverride: String?
    var scale: Double
    var reducedMotion: Bool
    var highContrast: Bool

    init(from prefs: ThemePreferences) {
        accentColorHex    = prefs.accentColor.hexString
        secondaryColorHex = prefs.secondaryColor.hexString
        fontOverride      = prefs.fontOverride
        scale             = prefs.scale
        reducedMotion     = prefs.reducedMotion
        highContrast      = prefs.highContrast
    }

    func toThemePreferences() -> ThemePreferences {
        ThemePreferences(
            accentColor:    Color(hex: accentColorHex),
            secondaryColor: Color(hex: secondaryColorHex),
            fontOverride:   fontOverride,
            scale:          scale,
            reducedMotion:  reducedMotion,
            highContrast:   highContrast
        )
    }
}
