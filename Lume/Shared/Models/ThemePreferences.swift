//  Akshay Shukla
//  ThemePreferences.swift
//  Lume
//
//  Per-theme appearance overrides supplied by ThemeEngine.
//  Themes use these values; users configure them in Settings.
//

import SwiftUI

// MARK: - ThemePreferences

struct ThemePreferences: Equatable {

    // MARK: Colors
    var accentColor: Color = .white
    var secondaryColor: Color = .white.opacity(0.6)
    var backgroundColor: Color = .clear

    // MARK: Typography
    var fontOverride: String? = nil   // nil = theme default font

    // MARK: Layout
    var scale: Double = 1.0           // multiplier on top of fontSize

    // MARK: Accessibility
    var reducedMotion: Bool = false
    var highContrast: Bool = false

    // MARK: - Defaults by color scheme

    static func defaultLight() -> ThemePreferences {
        ThemePreferences(
            accentColor: .black,
            secondaryColor: .black.opacity(0.5),
            backgroundColor: .clear
        )
    }

    static func defaultDark() -> ThemePreferences {
        ThemePreferences(
            accentColor: .white,
            secondaryColor: .white.opacity(0.55),
            backgroundColor: .clear
        )
    }
}
