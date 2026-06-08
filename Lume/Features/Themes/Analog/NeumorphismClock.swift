//  Akshay Shukla
//  NeumorphismClock.swift
//  Lume
//
//  Soft-UI / neumorphism analog clock.
//  Extruded disc with dual light/shadow, inset hands on a raised platform.
//  Works best on solid dark or light backgrounds.
//

import SwiftUI

struct NeumorphismClock: ClockTheme {
    let id: ClockThemeID = .neumorphism

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(NeumorphismClockView(time: time, prefs: prefs))
    }
}

// MARK: - View

private struct NeumorphismClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var base: Color { scheme == .dark ? Color(hex: "#1E1E2E") : Color(hex: "#E8ECF1") }
    private var light: Color { scheme == .dark ? Color(hex: "#2A2A40").opacity(0.8) : Color.white.opacity(0.8) }
    private var shadow: Color { scheme == .dark ? Color.black.opacity(0.5) : Color(hex: "#A0AABA").opacity(0.5) }
    private var accent: Color { prefs.accentColor }

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let r = d / 2
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                // Neumorphic disc — raised with dual shadow
                Circle()
                    .fill(base)
                    .frame(width: d, height: d)
                    .position(c)
                    .shadow(color: shadow, radius: 20, x: 10, y: 10)
                    .shadow(color: light, radius: 20, x: -10, y: -10)

                // Inner inset ring
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [light.opacity(0.6), shadow.opacity(0.3)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: d - 20, height: d - 20)
                    .position(c)

                // Hour dots
                Canvas { ctx, size in
                    for i in 0..<12 {
                        let angle = Double(i) * 30 * .pi / 180 - .pi/2
                        let dotR: CGFloat = i % 3 == 0 ? 4 : 2.5
                        let dist = r * 0.82
                        let dotC = CGPoint(
                            x: c.x + cos(angle) * dist,
                            y: c.y + sin(angle) * dist
                        )
                        let dot = Path(ellipseIn: CGRect(
                            x: dotC.x - dotR, y: dotC.y - dotR,
                            width: dotR * 2, height: dotR * 2
                        ))
                        ctx.fill(dot, with: .color(accent.opacity(0.7)))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // Hour hand — soft raised
                ClockHandView(
                    angle: .degrees(time.hourHandAngle),
                    length: r * 0.50,
                    width: 5,
                    color: accent.opacity(0.9),
                    tail: r * 0.10
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .shadow(color: shadow, radius: 4, x: 2, y: 2)
                .animation(.easeInOut(duration: 0.5), value: time.hours)

                // Minute hand
                ClockHandView(
                    angle: .degrees(time.minuteHandAngle),
                    length: r * 0.72,
                    width: 3,
                    color: accent.opacity(0.9),
                    tail: r * 0.08
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .shadow(color: shadow, radius: 3, x: 2, y: 2)
                .animation(.easeInOut(duration: 0.5), value: time.minutes)

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

                // Center hub — raised button
                Circle()
                    .fill(base)
                    .frame(width: 20, height: 20)
                    .shadow(color: shadow, radius: 3, x: 2, y: 2)
                    .shadow(color: light, radius: 3, x: -2, y: -2)
                    .position(c)
                Circle().fill(accent).frame(width: 8).position(c)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }
}
