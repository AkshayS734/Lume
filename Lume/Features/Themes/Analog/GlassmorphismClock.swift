//  Akshay Shukla
//  GlassmorphismClock.swift
//  Lume
//
//  Frosted-glass analog clock: blurred glass disc, soft luminous hands,
//  translucent tick marks. Works on any wallpaper color.
//

import SwiftUI

struct GlassmorphismClock: ClockTheme {
    let id: ClockThemeID = .glassmorphism

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(GlassmorphismClockView(time: time, prefs: prefs))
    }
}

// MARK: - View

private struct GlassmorphismClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let r = d / 2
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                // Glass disc background
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: d, height: d)
                    .position(c)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.glassBorder, lineWidth: 1)
                            .frame(width: d, height: d)
                            .position(c)
                    )

                // Tick marks — white, semi-transparent
                Canvas { ctx, size in
                    for i in 0..<60 {
                        let angle = Double(i) * 6 * .pi / 180
                        let isHour = i % 5 == 0
                        let len: CGFloat = isHour ? r * 0.10 : r * 0.05
                        let opacity: Double = isHour ? 0.7 : 0.3
                        let outer = CGPoint(
                            x: c.x + cos(angle - .pi/2) * r * 0.92,
                            y: c.y + sin(angle - .pi/2) * r * 0.92
                        )
                        let inner = CGPoint(
                            x: c.x + cos(angle - .pi/2) * (r * 0.92 - len),
                            y: c.y + sin(angle - .pi/2) * (r * 0.92 - len)
                        )
                        var p = Path(); p.move(to: outer); p.addLine(to: inner)
                        ctx.stroke(p,
                            with: .color(.white.opacity(opacity)),
                            lineWidth: isHour ? 2.5 : 1
                        )
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // Hour hand — frosted white with glow
                ClockHandView(
                    angle: .degrees(time.hourHandAngle),
                    length: r * 0.52,
                    width: 4,
                    color: .glassWhite,
                    tail: r * 0.10
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .glow(color: .white, radius: 8, intensity: 0.5)
                .animation(.easeInOut(duration: 0.5), value: time.hours)

                // Minute hand
                ClockHandView(
                    angle: .degrees(time.minuteHandAngle),
                    length: r * 0.73,
                    width: 2.5,
                    color: .glassWhite,
                    tail: r * 0.08
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .glow(color: .white, radius: 6, intensity: 0.4)
                .animation(.easeInOut(duration: 0.5), value: time.minutes)

                // Second hand — accent color glow
                ClockHandView(
                    angle: .degrees(time.secondHandAngle),
                    length: r * 0.82,
                    width: 1.2,
                    color: prefs.accentColor,
                    tail: r * 0.18
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .glow(color: prefs.accentColor, radius: 10, intensity: 0.8)
                .animation(
                    (prefs.reducedMotion || reduceMotion) ? .none : .linear(duration: 1.0),
                    value: time.secondHandAngle
                )

                // Center
                Circle().fill(Color.glassWhite).frame(width: 10).position(c)
                    .overlay(Circle().strokeBorder(Color.glassBorder, lineWidth: 1).frame(width: 10).position(c))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }
}
