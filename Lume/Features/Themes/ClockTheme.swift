//  Akshay Shukla
//  ClockTheme.swift
//  Lume
//
//  Protocol that every clock theme must conform to.
//  The theme engine calls makeView(time:prefs:) and embeds the result
//  directly into ClockView — no type erasure, no AnyView boxing at callsite.
//

import SwiftUI

// MARK: - ClockTheme Protocol

/// All clock themes conform to this protocol.
/// Themes are pure view factories — they hold no mutable state.
/// All state (time, user prefs) is injected at render time.
protocol ClockTheme {
    /// The stable identifier for this theme.
    var id: ClockThemeID { get }

    /// Human-readable name shown in the theme picker.
    var displayName: String { get }

    /// Category group in the picker.
    var category: ThemeCategory { get }

    /// Whether this theme is gated behind PremiumGate.
    var isPremium: Bool { get }

    /// Accessibility description of the time (e.g. "3:45 PM").
    /// Default implementation provided below.
    func accessibilityLabel(for time: ClockTime) -> String

    /// Produces the clock face view for a given time snapshot and appearance prefs.
    @ViewBuilder
    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView
}

// MARK: - Default implementations

extension ClockTheme {

    var displayName: String { id.displayName }
    var category: ThemeCategory { id.category }
    var isPremium: Bool { id.isPremium }

    func accessibilityLabel(for time: ClockTime) -> String {
        if time.is24Hour {
            return "The time is \(time.hoursString):\(time.minutesString)"
        } else {
            return "The time is \(time.hours12):\(time.minutesString) \(time.amPm)"
        }
    }
}

// MARK: - AnyClockTheme (type-erased wrapper)

/// Type-erased wrapper so ThemeEngine can store heterogeneous themes in an array.
struct AnyClockTheme: ClockTheme, Identifiable {
    let id: ClockThemeID
    private let _makeView: (ClockTime, ThemePreferences) -> AnyView
    private let _accessibilityLabel: (ClockTime) -> String

    init<T: ClockTheme>(_ base: T) {
        self.id = base.id
        self._makeView = { time, prefs in AnyView(base.makeView(time: time, prefs: prefs)) }
        self._accessibilityLabel = { time in base.accessibilityLabel(for: time) }
    }

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        _makeView(time, prefs)
    }

    func accessibilityLabel(for time: ClockTime) -> String {
        _accessibilityLabel(time)
    }
}

// MARK: - Global accessibility helper

/// Free function so private View structs inside theme files can
/// call this without conforming to ClockTheme.
func lumeTimeLabel(_ time: ClockTime) -> String {
    if time.is24Hour {
        return "The time is \(time.hoursString):\(time.minutesString)"
    } else {
        return "The time is \(time.hours12):\(time.minutesString) \(time.amPm)"
    }
}
