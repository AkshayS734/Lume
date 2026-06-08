//  Akshay Shukla
//  MinimalAnalogClock.swift
//  Lume
//
//  Apple-inspired minimal analog clock.
//  Thin hands, subtle tick marks, smooth second sweep via Canvas.
//

import SwiftUI

struct MinimalAnalogClock: ClockTheme {
    let id: ClockThemeID = .minimalAnalog

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(MinimalAnalogClockView(time: time, prefs: prefs))
    }
}

// MARK: - View

private struct MinimalAnalogClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Angles computed from ClockTime helpers
    private var secondAngle: Angle {
        if prefs.reducedMotion || reduceMotion {
            return .degrees(Double(time.seconds) * 6 - 90)
        }
        return .degrees(time.secondHandAngle)
    }

    private var minuteAngle: Angle { .degrees(time.minuteHandAngle) }
    private var hourAngle: Angle   { .degrees(time.hourHandAngle) }

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let r = d / 2
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                // Face — minimal, no fill
                Circle()
                    .strokeBorder(prefs.accentColor.opacity(0.2), lineWidth: 1.5)
                    .frame(width: d, height: d)
                    .position(c)

                // Tick marks
                Canvas { ctx, size in
                    for i in 0..<60 {
                        let isHour = i % 5 == 0
                        let angle = Double(i) * 6 * .pi / 180
                        let tickLen: CGFloat = isHour ? r * 0.10 : r * 0.05
                        let tickW: CGFloat = isHour ? 2 : 1
                        let outer = CGPoint(
                            x: c.x + cos(angle - .pi/2) * r,
                            y: c.y + sin(angle - .pi/2) * r
                        )
                        let inner = CGPoint(
                            x: c.x + cos(angle - .pi/2) * (r - tickLen),
                            y: c.y + sin(angle - .pi/2) * (r - tickLen)
                        )
                        var p = Path()
                        p.move(to: outer)
                        p.addLine(to: inner)
                        let opacity = isHour ? 0.7 : 0.3
                        ctx.stroke(p,
                            with: .color(prefs.accentColor.opacity(opacity)),
                            lineWidth: tickW
                        )
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // Hour hand
                ClockHandView(
                    angle: hourAngle,
                    length: r * 0.52,
                    width: 3.5,
                    color: prefs.accentColor,
                    tail: r * 0.08,
                    shadow: true
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(.easeInOut(duration: 0.5), value: hourAngle)

                // Minute hand
                ClockHandView(
                    angle: minuteAngle,
                    length: r * 0.73,
                    width: 2,
                    color: prefs.accentColor,
                    tail: r * 0.08
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(.easeInOut(duration: 0.5), value: minuteAngle)

                // Second hand (accent red)
                ClockHandView(
                    angle: secondAngle,
                    length: r * 0.82,
                    width: 1.2,
                    color: Color.clockRed,
                    tail: r * 0.20
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(
                    (prefs.reducedMotion || reduceMotion) ? .none : .linear(duration: 1.0),
                    value: secondAngle
                )

                // Center cap
                Circle()
                    .fill(prefs.accentColor)
                    .frame(width: 10, height: 10)
                    .position(c)

                Circle()
                    .fill(Color.clockRed)
                    .frame(width: 6, height: 6)
                    .position(c)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }
}
