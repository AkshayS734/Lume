//  Akshay Shukla
//  LuxuryWatchClock.swift  [Premium]
//  Lume
//
//  High-end watch dial: guilloché-textured face suggestion via Canvas,
//  gold/silver applied indices, sapphire-style minute track.
//

import SwiftUI

struct LuxuryWatchClock: ClockTheme {
    let id: ClockThemeID = .luxuryWatch

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(
            PremiumGate(feature: .luxuryWatch) {
                LuxuryWatchClockView(time: time, prefs: prefs)
            }
        )
    }
}

// MARK: - View

private struct LuxuryWatchClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Gold/silver palette
    private var gold: Color { prefs.accentColor == .white ? .clockGold : prefs.accentColor }
    private var silver: Color { .clockSilver }

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let r = d / 2
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                // Outer bezel ring
                Circle()
                    .strokeBorder(
                        LinearGradient(colors: [gold, silver, gold, silver, gold],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 8
                    )
                    .frame(width: d, height: d)
                    .position(c)

                // Applied hour indices (rectangular gold blocks)
                Canvas { ctx, size in
                    for i in 0..<12 {
                        let angle = Double(i) * 30 * .pi / 180
                        let isQuarter = i % 3 == 0
                        let w: CGFloat = isQuarter ? 8 : 5
                        let h: CGFloat = isQuarter ? r * 0.16 : r * 0.10
                        let dist = r * 0.82

                        let cx = c.x + cos(angle - .pi/2) * dist
                        let cy = c.y + sin(angle - .pi/2) * dist

                        var rect = Path(CGRect(x: cx - w/2, y: cy - h/2, width: w, height: h))
                        let transform = CGAffineTransform(translationX: cx, y: cy)
                            .rotated(by: angle)
                            .translatedBy(x: -cx, y: -cy)
                        rect = rect.applying(transform)

                        ctx.fill(rect, with: .color(gold))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // Minute track dots
                Canvas { ctx, size in
                    for i in 0..<60 {
                        guard i % 5 != 0 else { continue }
                        let angle = Double(i) * 6 * .pi / 180
                        let dotR: CGFloat = 1.5
                        let dist = r * 0.91
                        let dotC = CGPoint(
                            x: c.x + cos(angle - .pi/2) * dist,
                            y: c.y + sin(angle - .pi/2) * dist
                        )
                        let dot = Path(ellipseIn: CGRect(
                            x: dotC.x - dotR, y: dotC.y - dotR,
                            width: dotR * 2, height: dotR * 2
                        ))
                        ctx.fill(dot, with: .color(silver.opacity(0.5)))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // Dauphine hour hand
                ClockHandView(
                    angle: .degrees(time.hourHandAngle),
                    length: r * 0.50,
                    width: 6,
                    color: silver,
                    tail: r * 0.10,
                    shadow: true
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(.easeInOut(duration: 0.5), value: time.hours)

                // Dauphine minute hand
                ClockHandView(
                    angle: .degrees(time.minuteHandAngle),
                    length: r * 0.74,
                    width: 4,
                    color: silver,
                    tail: r * 0.10,
                    shadow: true
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(.easeInOut(duration: 0.5), value: time.minutes)

                // Seconds hand — thin gold
                ClockHandView(
                    angle: .degrees(time.secondHandAngle),
                    length: r * 0.82,
                    width: 1.0,
                    color: gold,
                    tail: r * 0.22
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(
                    (prefs.reducedMotion || reduceMotion) ? .none : .linear(duration: 1.0),
                    value: time.secondHandAngle
                )

                // Center jewel
                Circle().fill(silver).frame(width: 14).position(c)
                Circle().fill(gold).frame(width: 8).position(c)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }
}
