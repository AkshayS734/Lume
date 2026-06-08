//  Akshay Shukla
//  PixelClock.swift  [Premium]
//  Lume — chunky pixel-art style digital clock
//

import SwiftUI

struct PixelClock: ClockTheme {
    let id: ClockThemeID = .pixel

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(
            PremiumGate(feature: .pixelClock) {
                PixelClockView(time: time, prefs: prefs)
            }
        )
    }
}

// MARK: - 3×5 Pixel Font (chunky blocks)

private let pixelFont3x5: [Character: [[Bool]]] = [
    "0": [[1,1,1],[1,0,1],[1,0,1],[1,0,1],[1,1,1]],
    "1": [[0,1,0],[1,1,0],[0,1,0],[0,1,0],[1,1,1]],
    "2": [[1,1,1],[0,0,1],[0,1,0],[1,0,0],[1,1,1]],
    "3": [[1,1,1],[0,0,1],[0,1,1],[0,0,1],[1,1,1]],
    "4": [[1,0,1],[1,0,1],[1,1,1],[0,0,1],[0,0,1]],
    "5": [[1,1,1],[1,0,0],[1,1,1],[0,0,1],[1,1,1]],
    "6": [[1,1,1],[1,0,0],[1,1,1],[1,0,1],[1,1,1]],
    "7": [[1,1,1],[0,0,1],[0,1,0],[1,0,0],[1,0,0]],
    "8": [[1,1,1],[1,0,1],[1,1,1],[1,0,1],[1,1,1]],
    "9": [[1,1,1],[1,0,1],[1,1,1],[0,0,1],[1,1,1]],
].mapValues { rows in rows.map { row in row.map { $0 == 1 } } }

// MARK: - View

private struct PixelClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences

    private let pixelSize: CGFloat = 12
    private let gap: CGFloat = 3

    var body: some View {
        HStack(spacing: (pixelSize + gap * 3) * prefs.scale) {
            pixelGroup(time.hoursString)
            pixelColon
            pixelGroup(time.minutesString)
            pixelColon
            pixelGroup(time.secondsString)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }

    private func pixelGroup(_ str: String) -> some View {
        HStack(spacing: (pixelSize + gap) * prefs.scale) {
            ForEach(Array(str.enumerated()), id: \.offset) { _, ch in
                pixelDigit(Character(String(ch)))
            }
        }
    }

    private func pixelDigit(_ c: Character) -> some View {
        let rows = pixelFont3x5[c] ?? Array(repeating: Array(repeating: false, count: 3), count: 5)
        return VStack(spacing: gap * prefs.scale) {
            ForEach(0..<5, id: \.self) { r in
                HStack(spacing: gap * prefs.scale) {
                    ForEach(0..<3, id: \.self) { col in
                        let lit = rows[r][col]
                        RoundedRectangle(cornerRadius: 2 * prefs.scale)
                            .fill(lit ? prefs.accentColor : prefs.accentColor.opacity(0.07))
                            .frame(
                                width: pixelSize * prefs.scale,
                                height: pixelSize * prefs.scale
                            )
                            .animation(.easeInOut(duration: 0.15), value: lit)
                    }
                }
            }
        }
    }

    private var pixelColon: some View {
        VStack(spacing: pixelSize * prefs.scale) {
            RoundedRectangle(cornerRadius: 2 * prefs.scale)
                .fill(prefs.accentColor)
                .frame(width: pixelSize * 0.7 * prefs.scale, height: pixelSize * 0.7 * prefs.scale)
            RoundedRectangle(cornerRadius: 2 * prefs.scale)
                .fill(prefs.accentColor)
                .frame(width: pixelSize * 0.7 * prefs.scale, height: pixelSize * 0.7 * prefs.scale)
        }
        .padding(.top, pixelSize * prefs.scale * 0.5)
    }
}
