//  Akshay Shukla
//  BinaryClock.swift
//  Lume
//
//  Binary-coded decimal clock: 6 columns of 4 dots each (H1, H2, M1, M2, S1, S2).
//  Lit circles = 1, dim circles = 0. Educational and hypnotizing.
//

import SwiftUI

struct BinaryClock: ClockTheme {
    let id: ClockThemeID = .binary

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(BinaryClockView(time: time, prefs: prefs))
    }
}

// MARK: - BCD Helper

/// Converts an integer 0–59 into two BCD digit columns.
/// Each column is 4 bits, MSB first (index 0 = bit 3, index 3 = bit 0).
private func bcdColumns(_ value: Int) -> [[Bool]] {
    let tens = min(value / 10, 9)
    let ones = value % 10
    func bits(_ n: Int) -> [Bool] {
        (0..<4).reversed().map { n & (1 << $0) != 0 }
    }
    return [bits(tens), bits(ones)]
}

// MARK: - View

private struct BinaryClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences

    private let dotSize: CGFloat = 18
    private let rows = 4

    private var columns: [[Bool]] {
        bcdColumns(time.hours) + bcdColumns(time.minutes) + bcdColumns(time.seconds)
    }

    private let labels = ["H1","H2","M1","M2","S1","S2"]

    var body: some View {
        VStack(spacing: 20 * prefs.scale) {
            HStack(spacing: 16 * prefs.scale) {
                ForEach(Array(columns.enumerated()), id: \.offset) { colIdx, bits in
                    VStack(spacing: 10 * prefs.scale) {
                        // Dots — row 0 = MSB (top)
                        ForEach(0..<rows, id: \.self) { rowIdx in
                            let bit = bits[rowIdx]
                            Circle()
                                .fill(bit
                                      ? prefs.accentColor
                                      : prefs.accentColor.opacity(0.10))
                                .frame(
                                    width:  dotSize * prefs.scale,
                                    height: dotSize * prefs.scale
                                )
                                .glow(
                                    color: prefs.accentColor,
                                    radius: bit ? 8 : 0,
                                    intensity: bit ? 0.8 : 0
                                )
                                .animation(.easeInOut(duration: 0.25), value: bit)
                        }

                        // Column label
                        Text(labels[colIdx])
                            .font(.system(size: 10 * prefs.scale,
                                          weight: .medium,
                                          design: .monospaced))
                            .foregroundStyle(prefs.secondaryColor)
                    }
                }
            }

            // Decimal readout (helps new users read binary)
            Text(String(format: "%@:%@:%@",
                        time.hoursString,
                        time.minutesString,
                        time.secondsString))
                .font(.system(size: 14 * prefs.scale, weight: .light, design: .monospaced))
                .foregroundStyle(prefs.secondaryColor)
                .contentTransition(.numericText())
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }
}
