//  Akshay Shukla
//  DotMatrixClock.swift  [Premium]
//  Lume — 5×7 dot matrix digit renderer
//

import SwiftUI

struct DotMatrixClock: ClockTheme {
    let id: ClockThemeID = .dotMatrix

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(
            PremiumGate(feature: .dotMatrix) {
                DotMatrixClockView(time: time, prefs: prefs)
            }
        )
    }
}

// MARK: - 5×7 Bitmap Font

// Each digit is a 5×7 grid, row-major, bit 0 = top-left
private let dotFont5x7: [Character: [[Bool]]] = [
    "0": [[0,1,1,1,0],[1,0,0,0,1],[1,0,0,1,1],[1,0,1,0,1],[1,1,0,0,1],[1,0,0,0,1],[0,1,1,1,0]],
    "1": [[0,0,1,0,0],[0,1,1,0,0],[0,0,1,0,0],[0,0,1,0,0],[0,0,1,0,0],[0,0,1,0,0],[0,1,1,1,0]],
    "2": [[0,1,1,1,0],[1,0,0,0,1],[0,0,0,0,1],[0,0,0,1,0],[0,0,1,0,0],[0,1,0,0,0],[1,1,1,1,1]],
    "3": [[1,1,1,1,1],[0,0,0,1,0],[0,0,1,0,0],[0,0,0,1,0],[0,0,0,0,1],[1,0,0,0,1],[0,1,1,1,0]],
    "4": [[0,0,0,1,0],[0,0,1,1,0],[0,1,0,1,0],[1,0,0,1,0],[1,1,1,1,1],[0,0,0,1,0],[0,0,0,1,0]],
    "5": [[1,1,1,1,1],[1,0,0,0,0],[1,1,1,1,0],[0,0,0,0,1],[0,0,0,0,1],[1,0,0,0,1],[0,1,1,1,0]],
    "6": [[0,1,1,1,0],[1,0,0,0,0],[1,0,0,0,0],[1,1,1,1,0],[1,0,0,0,1],[1,0,0,0,1],[0,1,1,1,0]],
    "7": [[1,1,1,1,1],[0,0,0,0,1],[0,0,0,1,0],[0,0,1,0,0],[0,1,0,0,0],[0,1,0,0,0],[0,1,0,0,0]],
    "8": [[0,1,1,1,0],[1,0,0,0,1],[1,0,0,0,1],[0,1,1,1,0],[1,0,0,0,1],[1,0,0,0,1],[0,1,1,1,0]],
    "9": [[0,1,1,1,0],[1,0,0,0,1],[1,0,0,0,1],[0,1,1,1,1],[0,0,0,0,1],[0,0,0,0,1],[0,1,1,1,0]],
].mapValues { rows in rows.map { row in row.map { $0 == 1 } } }

// MARK: - View

private struct DotMatrixClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences

    private let dotSize: CGFloat = 5
    private let dotGap: CGFloat  = 2
    private let charGap: CGFloat = 8

    private func firstChar(_ s: String) -> Character { s.first ?? "0" }
    private func lastChar(_ s: String) -> Character { s.last ?? "0" }

    var body: some View {
        HStack(spacing: charGap * prefs.scale) {
            digitView(char: firstChar(time.hoursString))
            digitView(char: lastChar(time.hoursString))
            colonView
            digitView(char: firstChar(time.minutesString))
            digitView(char: lastChar(time.minutesString))
            colonView
            digitView(char: firstChar(time.secondsString))
            digitView(char: lastChar(time.secondsString))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }

    private func digitView(char: Character) -> some View {
        let rows = dotFont5x7[char] ?? Array(repeating: Array(repeating: false, count: 5), count: 7)
        let sz = (dotSize + dotGap) * prefs.scale
        return VStack(spacing: dotGap * prefs.scale) {
            ForEach(0..<7, id: \.self) { r in
                HStack(spacing: dotGap * prefs.scale) {
                    ForEach(0..<5, id: \.self) { c in
                        let lit = rows[r][c]
                        Circle()
                            .fill(lit ? prefs.accentColor : prefs.accentColor.opacity(0.08))
                            .frame(width: dotSize * prefs.scale, height: dotSize * prefs.scale)
                            .animation(.easeInOut(duration: 0.2), value: lit)
                    }
                }
            }
        }
    }

    private var colonView: some View {
        VStack(spacing: (dotSize + dotGap) * prefs.scale * 2) {
            Circle().fill(prefs.accentColor)
                .frame(width: dotSize * prefs.scale, height: dotSize * prefs.scale)
            Circle().fill(prefs.accentColor)
                .frame(width: dotSize * prefs.scale, height: dotSize * prefs.scale)
        }
        .padding(.top, (dotSize + dotGap) * prefs.scale * 1.5)
    }
}
