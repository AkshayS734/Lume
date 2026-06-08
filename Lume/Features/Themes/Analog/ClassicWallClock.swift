//  Akshay Shukla
//  ClassicWallClock.swift
//  Lume
//
//  Traditional Roman-numeral wall clock.
//  Warm cream face, serif numerals, ornate bezel.
//

import SwiftUI

struct ClassicWallClock: ClockTheme {
    let id: ClockThemeID = .classicWall

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(ClassicWallClockView(time: time, prefs: prefs))
    }
}

// MARK: - Roman Numerals

private let romanNumerals = ["XII","I","II","III","IV","V","VI","VII","VIII","IX","X","XI"]

// MARK: - View

private struct ClassicWallClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var faceColor: Color { .warmWhite.opacity(0.04) }
    private var bezelColor: Color { prefs.accentColor }
    private var handColor: Color  { prefs.accentColor }

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let r = d / 2
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                // Outer bezel — double ring
                Circle()
                    .strokeBorder(bezelColor, lineWidth: 6)
                    .frame(width: d, height: d)
                    .position(c)
                Circle()
                    .strokeBorder(bezelColor.opacity(0.3), lineWidth: 2)
                    .frame(width: d - 16, height: d - 16)
                    .position(c)

                // Roman numerals
                ForEach(0..<12) { i in
                    let angle = Double(i) * 30 * .pi / 180 - .pi / 2
                    let numR = r * 0.76
                    Text(romanNumerals[i])
                        .font(.system(size: r * 0.13, weight: .light, design: .serif))
                        .foregroundStyle(bezelColor)
                        .position(
                            x: c.x + cos(angle) * numR,
                            y: c.y + sin(angle) * numR
                        )
                }

                // Minute ticks
                Canvas { ctx, size in
                    for i in 0..<60 {
                        guard i % 5 != 0 else { continue }
                        let angle = Double(i) * 6 * .pi / 180
                        let inner = CGPoint(
                            x: c.x + cos(angle - .pi/2) * (r * 0.88),
                            y: c.y + sin(angle - .pi/2) * (r * 0.88)
                        )
                        let outer = CGPoint(
                            x: c.x + cos(angle - .pi/2) * (r * 0.94),
                            y: c.y + sin(angle - .pi/2) * (r * 0.94)
                        )
                        var p = Path(); p.move(to: inner); p.addLine(to: outer)
                        ctx.stroke(p, with: .color(bezelColor.opacity(0.4)), lineWidth: 1)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // Hour hand — ornate, wider
                ClockHandView(
                    angle: .degrees(time.hourHandAngle),
                    length: r * 0.50,
                    width: 5,
                    color: handColor,
                    tail: r * 0.10,
                    shadow: true
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(.easeInOut(duration: 0.6), value: time.hours)

                // Minute hand
                ClockHandView(
                    angle: .degrees(time.minuteHandAngle),
                    length: r * 0.72,
                    width: 3.5,
                    color: handColor,
                    tail: r * 0.10,
                    shadow: true
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(.easeInOut(duration: 0.6), value: time.minutes)

                // Second hand
                ClockHandView(
                    angle: .degrees(time.secondHandAngle),
                    length: r * 0.80,
                    width: 1.5,
                    color: Color.clockRed,
                    tail: r * 0.18
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(
                    (prefs.reducedMotion || reduceMotion) ? .none : .linear(duration: 1.0),
                    value: time.secondHandAngle
                )

                // Center ornament
                Circle().fill(handColor).frame(width: 12).position(c)
                Circle().fill(Color.clockRed).frame(width: 7).position(c)
                Circle().strokeBorder(handColor, lineWidth: 1).frame(width: 18).position(c)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }
}
