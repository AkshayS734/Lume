//  Akshay Shukla
//  FlipClock.swift  [Premium]
//  Lume
//
//  Mechanical flip-card clock with 3D card-flip animation.
//  Uses rotation3DEffect for realistic card turn on each digit change.
//

import SwiftUI

struct FlipClock: ClockTheme {
    let id: ClockThemeID = .flip

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(
            PremiumGate(feature: .flipClock) {
                FlipClockView(time: time, prefs: prefs)
            }
        )
    }
}

// MARK: - View

private struct FlipClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences

    var body: some View {
        VStack(spacing: 16 * prefs.scale) {
            HStack(spacing: 10 * prefs.scale) {
                FlipDigitGroup(value: time.hoursString,   scale: prefs.scale, accent: prefs.accentColor)
                FlipSeparator(scale: prefs.scale, color: prefs.accentColor)
                FlipDigitGroup(value: time.minutesString, scale: prefs.scale, accent: prefs.accentColor)
                FlipSeparator(scale: prefs.scale, color: prefs.accentColor)
                FlipDigitGroup(value: time.secondsString, scale: prefs.scale, accent: prefs.accentColor)
            }

            // AM/PM
            if !time.is24Hour && !time.amPm.isEmpty {
                Text(time.amPm)
                    .font(.system(size: 20 * prefs.scale, weight: .semibold, design: .rounded))
                    .foregroundStyle(prefs.secondaryColor)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }
}

// MARK: - Digit Group

private struct FlipDigitGroup: View {
    let value: String
    let scale: Double
    let accent: Color

    var body: some View {
        HStack(spacing: 3 * scale) {
            ForEach(Array(value.enumerated()), id: \.offset) { _, char in
                FlipCard(digit: String(char), scale: scale, accent: accent)
            }
        }
    }
}

// MARK: - Separator

private struct FlipSeparator: View {
    let scale: Double
    let color: Color

    var body: some View {
        VStack(spacing: 18 * scale) {
            Circle().fill(color).frame(width: 7 * scale, height: 7 * scale)
            Circle().fill(color).frame(width: 7 * scale, height: 7 * scale)
        }
        .offset(y: -4 * scale)
    }
}

// MARK: - Individual Flip Card

private struct FlipCard: View {
    let digit: String
    let scale: Double
    let accent: Color

    @State private var flipping = false
    @State private var lastDigit: String = ""
    @State private var topDigit: String = ""

    private let cardW: CGFloat = 64
    private let cardH: CGFloat = 88

    var body: some View {
        ZStack {
            // Bottom half (new digit — revealed after flip)
            CardHalf(digit: digit, half: .bottom, scale: scale, accent: accent)

            // Top half (old digit — flips away)
            CardHalf(digit: topDigit.isEmpty ? digit : topDigit, half: .top, scale: scale, accent: accent)
                .rotation3DEffect(
                    .degrees(flipping ? -90 : 0),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .center,
                    perspective: 0.4
                )
                .zIndex(1)

            // New top (comes in after)
            if flipping {
                CardHalf(digit: digit, half: .top, scale: scale, accent: accent)
                    .rotation3DEffect(
                        .degrees(flipping ? 0 : 90),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .center,
                        perspective: 0.4
                    )
                    .zIndex(2)
            }
        }
        .frame(width: cardW * scale, height: cardH * scale)
        .onChange(of: digit) { old, new in
            guard new != old else { return }
            topDigit = old
            withAnimation(.easeIn(duration: 0.15)) { flipping = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                withAnimation(.easeOut(duration: 0.13)) { flipping = false }
                topDigit = new
            }
        }
    }
}

// MARK: - Card Half

private struct CardHalf: View {
    let digit: String
    enum Half { case top, bottom }
    let half: Half
    let scale: Double
    let accent: Color

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 8 * scale, style: .continuous)
                    .fill(Color(hex: "#1A1A2E"))

                // Digit (clipped to half)
                Text(digit)
                    .font(.system(size: 72 * scale, weight: .bold, design: .monospaced))
                    .foregroundStyle(accent)
                    .frame(width: geo.size.width, height: geo.size.height * 2)
                    .offset(y: half == .bottom ? -geo.size.height / 2 : geo.size.height / 2)

                // Crease line
                if half == .bottom {
                    Rectangle()
                        .fill(Color.black.opacity(0.25))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: half == .top ? 0 : 8 * scale, style: .continuous))
            .frame(height: geo.size.height / 2)
            .frame(maxHeight: .infinity, alignment: half == .top ? .bottom : .top)
        }
    }
}
