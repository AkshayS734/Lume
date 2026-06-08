//  Akshay Shukla
//  MinimalDigitalClock.swift
//  Lume
//
//  Clean, SF-Pro ultralight digital clock — the default Lume theme.
//  Preserves the aesthetic of the original single-theme implementation.
//

import SwiftUI

struct MinimalDigitalClock: ClockTheme {
    let id: ClockThemeID = .minimalDigital

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(MinimalDigitalClockView(time: time, prefs: prefs))
    }
}

// MARK: - View

private struct MinimalDigitalClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences
    @Environment(\.colorScheme) private var scheme

    private var primary: Color { prefs.accentColor }
    private var secondary: Color { prefs.secondaryColor }
    private var glow: Color { primary.opacity(0.12) }

    var body: some View {
        VStack(spacing: 0) {
            timeRow
            Spacer().frame(height: 8 * prefs.scale)
            dateRow
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }

    // MARK: Time

    private var timeRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            MonoDigit(text: time.hoursString,   size: 72 * prefs.scale, weight: .ultraLight, color: primary)
            Text(":")
                .font(.system(size: 65 * prefs.scale, weight: .ultraLight))
                .foregroundStyle(primary.opacity(0.6))
            MonoDigit(text: time.minutesString, size: 72 * prefs.scale, weight: .ultraLight, color: primary)

            // Seconds — smaller, baseline-aligned
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)
                MonoDigit(
                    text: time.secondsString,
                    size: 72 * 0.38 * prefs.scale,
                    weight: .ultraLight,
                    color: primary.opacity(0.65)
                )
                .padding(.leading, 5 * prefs.scale)
            }
            .frame(height: 72 * 0.80 * prefs.scale)

            // AM/PM
            if !time.is24Hour && !time.amPm.isEmpty {
                Text(" \(time.amPm)")
                    .font(.system(size: 72 * 0.25 * prefs.scale, weight: .light))
                    .foregroundStyle(secondary)
                    .padding(.leading, 4 * prefs.scale)
                    .contentTransition(.numericText())
            }
        }
        .foregroundStyle(primary)
        .shadow(color: glow, radius: 20, x: 0, y: 2)
        .shadow(color: glow, radius: 40, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.6), value: time.hoursString)
        .animation(.easeInOut(duration: 0.6), value: time.minutesString)
    }

    // MARK: Date

    private var dateRow: some View {
        Text(time.dateString.uppercased())
            .font(.system(size: 72 * 0.18 * prefs.scale, weight: .regular))
            .kerning(72 * 0.06 * prefs.scale)
            .foregroundStyle(secondary)
            .shadow(color: glow, radius: 10)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.6), value: time.dateString)
    }
}
