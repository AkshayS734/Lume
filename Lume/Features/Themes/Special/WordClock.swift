//  Akshay Shukla
//  WordClock.swift  [Premium]
//  Lume
//
//  English word clock — lights up words to read the time naturally:
//  "IT IS QUARTER PAST TWO"
//

import SwiftUI

struct WordClock: ClockTheme {
    let id: ClockThemeID = .word

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(
            PremiumGate(feature: .wordClock) {
                WordClockView(time: time, prefs: prefs)
            }
        )
    }
}

// MARK: - Logic

/// Returns the set of word tokens that should be lit for the given time.
private func activeWords(for time: ClockTime) -> Set<String> {
    var words: Set<String> = ["IT", "IS"]

    let h = time.hours12
    let m = time.minutes

    // Minute words
    switch m {
    case 0:       words.insert("OCLOCK")
    case 1:       words.formUnion(["ONE_M", "MINUTE", "PAST"])
    case 2:       words.formUnion(["TWO_M", "MINUTES", "PAST"])
    case 3:       words.formUnion(["THREE_M", "MINUTES", "PAST"])
    case 4:       words.formUnion(["FOUR_M", "MINUTES", "PAST"])
    case 5:       words.formUnion(["FIVE_M", "MINUTES", "PAST"])
    case 6...9:   words.formUnion(["FIVE_M", "MINUTES", "PAST"])
    case 10:      words.formUnion(["TEN_M", "MINUTES", "PAST"])
    case 11...14: words.formUnion(["TEN_M", "MINUTES", "PAST"])
    case 15:      words.formUnion(["QUARTER", "PAST"])
    case 16...19: words.formUnion(["QUARTER", "PAST"])
    case 20:      words.formUnion(["TWENTY", "MINUTES", "PAST"])
    case 21...24: words.formUnion(["TWENTY", "MINUTES", "PAST"])
    case 25:      words.formUnion(["TWENTY", "FIVE_M", "MINUTES", "PAST"])
    case 26...29: words.formUnion(["TWENTY", "FIVE_M", "MINUTES", "PAST"])
    case 30:      words.formUnion(["HALF", "PAST"])
    case 31...34: words.formUnion(["HALF", "PAST"])
    case 35:      words.formUnion(["TWENTY", "FIVE_M", "MINUTES", "TO"])
    case 36...39: words.formUnion(["TWENTY", "FIVE_M", "MINUTES", "TO"])
    case 40:      words.formUnion(["TWENTY", "MINUTES", "TO"])
    case 41...44: words.formUnion(["TWENTY", "MINUTES", "TO"])
    case 45:      words.formUnion(["QUARTER", "TO"])
    case 46...49: words.formUnion(["QUARTER", "TO"])
    case 50:      words.formUnion(["TEN_M", "MINUTES", "TO"])
    case 51...54: words.formUnion(["TEN_M", "MINUTES", "TO"])
    case 55:      words.formUnion(["FIVE_M", "MINUTES", "TO"])
    case 56...59: words.formUnion(["FIVE_M", "MINUTES", "TO"])
    default: break
    }

    // Hour word — advance on "to" cases
    let displayHour = m >= 35 ? (h % 12 == 11 ? 12 : h + 1) : h
    let hourWords = ["TWELVE","ONE_H","TWO_H","THREE_H","FOUR_H","FIVE_H",
                     "SIX_H","SEVEN_H","EIGHT_H","NINE_H","TEN_H","ELEVEN_H","TWELVE"]
    if displayHour >= 1 && displayHour <= 12 {
        words.insert(hourWords[displayHour - 1])
    }

    return words
}

// MARK: - Grid Definition

private struct WordRow: Identifiable {
    let id = UUID()
    let tokens: [WordToken]
}

private struct WordToken: Identifiable {
    let id = UUID()
    let display: String   // shown text
    let key: String       // matched against activeWords
}

private let wordGrid: [WordRow] = [
    WordRow(tokens: [.init(display: "IT",      key: "IT"),
                     .init(display: "IS",      key: "IS"),
                     .init(display: "HALF",    key: "HALF"),
                     .init(display: "QUARTER", key: "QUARTER")]),
    WordRow(tokens: [.init(display: "TWENTY",  key: "TWENTY"),
                     .init(display: "FIVE",    key: "FIVE_M"),
                     .init(display: "MINUTES", key: "MINUTES")]),
    WordRow(tokens: [.init(display: "PAST",    key: "PAST"),
                     .init(display: "TO",      key: "TO"),
                     .init(display: "TEN",     key: "TEN_M"),
                     .init(display: "MINUTE",  key: "MINUTE")]),
    WordRow(tokens: [.init(display: "ONE",     key: "ONE_H"),
                     .init(display: "TWO",     key: "TWO_H"),
                     .init(display: "THREE",   key: "THREE_H"),
                     .init(display: "FOUR",    key: "FOUR_H")]),
    WordRow(tokens: [.init(display: "FIVE",    key: "FIVE_H"),
                     .init(display: "SIX",     key: "SIX_H"),
                     .init(display: "SEVEN",   key: "SEVEN_H")]),
    WordRow(tokens: [.init(display: "EIGHT",   key: "EIGHT_H"),
                     .init(display: "NINE",    key: "NINE_H"),
                     .init(display: "TEN",     key: "TEN_H")]),
    WordRow(tokens: [.init(display: "ELEVEN",  key: "ELEVEN_H"),
                     .init(display: "TWELVE",  key: "TWELVE"),
                     .init(display: "O'CLOCK", key: "OCLOCK")]),
]

// MARK: - View

private struct WordClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences

    private var lit: Set<String> { activeWords(for: time) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14 * prefs.scale) {
            ForEach(wordGrid) { row in
                HStack(spacing: 14 * prefs.scale) {
                    ForEach(row.tokens) { token in
                        let isLit = lit.contains(token.key)
                        Text(token.display)
                            .font(.system(size: 22 * prefs.scale, weight: .semibold, design: .rounded))
                            .foregroundStyle(isLit ? prefs.accentColor : prefs.accentColor.opacity(0.12))
                            .glow(color: prefs.accentColor, radius: isLit ? 6 : 0, intensity: isLit ? 0.6 : 0)
                            .animation(.easeInOut(duration: 0.4), value: isLit)
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }
}
