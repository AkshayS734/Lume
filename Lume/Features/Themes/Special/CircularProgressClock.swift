//  Akshay Shukla
//  CircularProgressClock.swift
//  Lume
//
//  Three concentric arcs showing seconds/minutes/hours as progress rings.
//  Clean, modern, Apple Watch-inspired.
//

import SwiftUI

struct CircularProgressClock: ClockTheme {
    let id: ClockThemeID = .circularProgress

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(CircularProgressClockView(time: time, prefs: prefs))
    }
}

// MARK: - View

private struct CircularProgressClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences

    private var secondProgress: Double { Double(time.seconds) / 60.0 }
    private var minuteProgress: Double { Double(time.minutes) / 60.0 }
    private var hourProgress: Double   { Double(time.hours % 12) / 12.0 }

    // Color sequence for the three rings
    private var ringColors: [Color] {
        [
            prefs.accentColor,
            prefs.accentColor.opacity(0.7),
            prefs.accentColor.opacity(0.45)
        ]
    }

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let spacing: CGFloat = d * 0.055
            let lineW: CGFloat = d * 0.045

            ZStack {
                // Three progress arcs (seconds outer, minutes mid, hours inner)
                ForEach(0..<3) { i in
                    let r = d / 2 - CGFloat(i) * (lineW + spacing)
                    let progress = [secondProgress, minuteProgress, hourProgress][i]
                    let color = ringColors[i]

                    // Track
                    Circle()
                        .stroke(color.opacity(0.12), lineWidth: lineW)
                        .frame(width: r * 2, height: r * 2)
                        .position(c)

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(color, style: StrokeStyle(lineWidth: lineW, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: r * 2, height: r * 2)
                        .position(c)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                        .glow(color: color, radius: 6, intensity: 0.5)
                }

                // Center time display
                VStack(spacing: 2) {
                    Text("\(time.hoursString):\(time.minutesString)")
                        .font(.system(size: d * 0.16, weight: .light, design: .rounded))
                        .foregroundStyle(prefs.accentColor)
                        .contentTransition(.numericText())

                    Text(time.secondsString + "s")
                        .font(.system(size: d * 0.07, weight: .light, design: .monospaced))
                        .foregroundStyle(prefs.secondaryColor)
                        .contentTransition(.numericText())
                }
                .position(c)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }
}
