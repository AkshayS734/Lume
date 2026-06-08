//  Akshay Shukla
//  LEDClock.swift
//  Lume
//
//  Seven-segment LED display rendered with Canvas paths.
//  Amber glow by default; user accent color overrides the LED color.
//

import SwiftUI

struct LEDClock: ClockTheme {
    let id: ClockThemeID = .led

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(LEDClockView(time: time, prefs: prefs))
    }
}

// MARK: - Seven-Segment Logic

/// Segment layout: a=top, b=top-right, c=bot-right, d=bottom, e=bot-left, f=top-left, g=middle
private let segmentMap: [Character: [Bool]] = [
    //          a      b      c      d      e      f      g
    "0": [true,  true,  true,  true,  true,  true,  false],
    "1": [false, true,  true,  false, false, false, false],
    "2": [true,  true,  false, true,  true,  false, true],
    "3": [true,  true,  true,  true,  false, false, true],
    "4": [false, true,  true,  false, false, true,  true],
    "5": [true,  false, true,  true,  false, true,  true],
    "6": [true,  false, true,  true,  true,  true,  true],
    "7": [true,  true,  true,  false, false, false, false],
    "8": [true,  true,  true,  true,  true,  true,  true],
    "9": [true,  true,  true,  true,  false, true,  true],
    " ": [false, false, false, false, false, false, false],
]

// MARK: - View

private struct LEDClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences

    private var ledColor: Color { prefs.accentColor == .white ? .clockAmber : prefs.accentColor }
    private var offColor: Color { ledColor.opacity(0.08) }
    private let digitW: CGFloat = 44
    private let digitH: CGFloat = 80

    var body: some View {
        VStack(spacing: 12 * prefs.scale) {
            HStack(spacing: 8 * prefs.scale) {
                digitGroup(time.hoursString)
                colonView
                digitGroup(time.minutesString)
                colonView
                digitGroup(time.secondsString)
            }

            if !time.is24Hour && !time.amPm.isEmpty {
                Text(time.amPm)
                    .font(.system(size: 18 * prefs.scale, weight: .medium, design: .monospaced))
                    .foregroundStyle(ledColor)
                    .glow(color: ledColor, radius: 6, intensity: 0.6)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
    }

    private func digitGroup(_ str: String) -> some View {
        HStack(spacing: 4 * prefs.scale) {
            ForEach(Array(str.enumerated()), id: \.offset) { _, ch in
                SevenSegmentDigit(
                    character: ch,
                    width: digitW * prefs.scale,
                    height: digitH * prefs.scale,
                    onColor: ledColor,
                    offColor: offColor
                )
                .glow(color: ledColor, radius: 10, intensity: 0.65)
            }
        }
    }

    private var colonView: some View {
        VStack(spacing: digitH * 0.22 * prefs.scale) {
            Circle().fill(ledColor).frame(width: 8 * prefs.scale, height: 8 * prefs.scale)
            Circle().fill(ledColor).frame(width: 8 * prefs.scale, height: 8 * prefs.scale)
        }
        .glow(color: ledColor, radius: 8, intensity: 0.6)
    }
}

// MARK: - SevenSegmentDigit

private struct SevenSegmentDigit: View {
    let character: Character
    let width: CGFloat
    let height: CGFloat
    let onColor: Color
    let offColor: Color

    private var segments: [Bool] {
        segmentMap[character] ?? Array(repeating: false, count: 7)
    }

    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height
            let sw = w * 0.13   // segment width
            let gap: CGFloat = 2

            let segs = segments
            let mid = h / 2

            // Segment paths: a b c d e f g
            let paths: [Path] = [
                // a: top horizontal
                hSegment(x: sw + gap, y: 0, w: w - 2*(sw+gap), sw: sw),
                // b: top-right vertical
                vSegment(x: w - sw, y: sw + gap, h: mid - sw - 2*gap, sw: sw),
                // c: bot-right vertical
                vSegment(x: w - sw, y: mid + gap, h: mid - sw - 2*gap, sw: sw),
                // d: bottom horizontal
                hSegment(x: sw + gap, y: h - sw, w: w - 2*(sw+gap), sw: sw),
                // e: bot-left vertical
                vSegment(x: 0, y: mid + gap, h: mid - sw - 2*gap, sw: sw),
                // f: top-left vertical
                vSegment(x: 0, y: sw + gap, h: mid - sw - 2*gap, sw: sw),
                // g: middle horizontal
                hSegment(x: sw + gap, y: mid - sw/2, w: w - 2*(sw+gap), sw: sw),
            ]

            for (i, path) in paths.enumerated() {
                ctx.fill(path, with: .color(segs[i] ? onColor : offColor))
            }
        }
        .frame(width: width, height: height)
    }

    private func hSegment(x: CGFloat, y: CGFloat, w: CGFloat, sw: CGFloat) -> Path {
        let cap = sw * 0.45
        var p = Path()
        p.move(to: CGPoint(x: x + cap, y: y))
        p.addLine(to: CGPoint(x: x + w - cap, y: y))
        p.addLine(to: CGPoint(x: x + w, y: y + sw/2))
        p.addLine(to: CGPoint(x: x + w - cap, y: y + sw))
        p.addLine(to: CGPoint(x: x + cap, y: y + sw))
        p.addLine(to: CGPoint(x: x, y: y + sw/2))
        p.closeSubpath()
        return p
    }

    private func vSegment(x: CGFloat, y: CGFloat, h: CGFloat, sw: CGFloat) -> Path {
        let cap = sw * 0.45
        var p = Path()
        p.move(to: CGPoint(x: x, y: y + cap))
        p.addLine(to: CGPoint(x: x + sw/2, y: y))
        p.addLine(to: CGPoint(x: x + sw, y: y + cap))
        p.addLine(to: CGPoint(x: x + sw, y: y + h - cap))
        p.addLine(to: CGPoint(x: x + sw/2, y: y + h))
        p.addLine(to: CGPoint(x: x, y: y + h - cap))
        p.closeSubpath()
        return p
    }
}
