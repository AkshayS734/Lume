//  Akshay Shukla
//  ThemeRegistry.swift
//  Lume
//
//  Central registry that maps ClockThemeID → AnyClockTheme.
//  To add a new theme: implement ClockTheme, then add one line here.
//

import Foundation

// MARK: - ThemeRegistry

enum ThemeRegistry {

    // MARK: - All themes (ordered for display in picker)

    static let all: [AnyClockTheme] = [
        // Analog
        AnyClockTheme(MinimalAnalogClock()),
        AnyClockTheme(SwissRailwayClock()),
        AnyClockTheme(ClassicWallClock()),
        AnyClockTheme(LuxuryWatchClock()),
        AnyClockTheme(GlassmorphismClock()),
        AnyClockTheme(NeumorphismClock()),
        // Digital
        AnyClockTheme(MinimalDigitalClock()),
        AnyClockTheme(LEDClock()),
        AnyClockTheme(FlipClock()),
        AnyClockTheme(TerminalClock()),
        AnyClockTheme(DotMatrixClock()),
        AnyClockTheme(PixelClock()),
        // Special
        AnyClockTheme(BinaryClock()),
        AnyClockTheme(WordClock()),
        AnyClockTheme(CircularProgressClock()),
        AnyClockTheme(FuturisticClock()),
    ]

    // MARK: - Lookup

    /// Returns the theme for a given ID, or MinimalDigital as a safe fallback.
    static func theme(for id: ClockThemeID) -> AnyClockTheme {
        all.first { $0.id == id } ?? AnyClockTheme(MinimalDigitalClock())
    }

    // MARK: - Grouped access

    static var byCategory: [ThemeCategory: [AnyClockTheme]] {
        Dictionary(grouping: all) { $0.category }
    }
}
