//  Akshay Shukla
//  SwissRailwayClock.swift
//  Lume
//
//  SBB (Swiss Federal Railways) clock — iconic baton hands,
//  rectangular minute markers, and the characteristic lollipop second hand.
//

import SwiftUI

struct SwissRailwayClock: ClockTheme {
    let id: ClockThemeID = .swissRailway

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(SwissRailwayClockView(time: time, prefs: prefs))
    }
}

// MARK: - View

private struct SwissRailwayClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Swiss second hand animates from 0→~58.5s smoothly, then jumps to 60
    @State private var displayedSeconds: Double = 0

    private var minuteAngle: Angle { .degrees(time.minuteHandAngle) }
    private var hourAngle:   Angle { .degrees(time.hourHandAngle) }
    private var secondAngle: Angle { .degrees(displayedSeconds * 6 - 90) }

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let r = d / 2
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                // Outer bezel
                Circle()
                    .strokeBorder(prefs.accentColor, lineWidth: 4)
                    .frame(width: d, height: d)
                    .position(c)

                // Hour blocks (12 thick rectangles)
                Canvas { ctx, size in
                    for i in 0..<60 {
                        let angle = Double(i) * 6 * .pi / 180
                        let isHour   = i % 5 == 0
                        let isQuarter = i % 15 == 0

                        let w: CGFloat = isQuarter ? 10 : isHour ? 6 : 2
                        let h: CGFloat = isQuarter ? r * 0.22 : isHour ? r * 0.16 : r * 0.08
                        let opacity: Double = isHour ? 1.0 : 0.4

                        let cx = c.x + cos(angle - .pi/2) * (r - h/2)
                        let cy = c.y + sin(angle - .pi/2) * (r - h/2)

                        var rect = Path(CGRect(x: cx - w/2, y: cy - h/2, width: w, height: h))
                        var transform = CGAffineTransform(translationX: cx, y: cy)
                            .rotated(by: angle)
                            .translatedBy(x: -cx, y: -cy)
                        rect = rect.applying(transform)

                        ctx.fill(rect, with: .color(prefs.accentColor.opacity(opacity)))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // Hour hand — wide baton
                BatonHandView(
                    angle: hourAngle,
                    length: r * 0.50,
                    width: r * 0.055,
                    color: prefs.accentColor,
                    tail: r * 0.12
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(.easeInOut(duration: 0.5), value: hourAngle)

                // Minute hand — longer, slightly narrower baton
                BatonHandView(
                    angle: minuteAngle,
                    length: r * 0.77,
                    width: r * 0.040,
                    color: prefs.accentColor,
                    tail: r * 0.12
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(.easeInOut(duration: 0.5), value: minuteAngle)

                // Second hand — lollipop style
                SwissSecondHandCanvas(
                    angle: secondAngle,
                    r: r,
                    center: c,
                    color: Color.clockRed
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(
                    (prefs.reducedMotion || reduceMotion) ? .none : .linear(duration: 1.0),
                    value: secondAngle
                )

                // Center hub
                Circle().fill(prefs.accentColor).frame(width: r * 0.08).position(c)
                Circle().fill(Color.clockRed).frame(width: r * 0.05).position(c)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
        .onChange(of: time.seconds) { _, newSec in
            guard !reduceMotion && !prefs.reducedMotion else {
                displayedSeconds = Double(newSec)
                return
            }
            // SBB rhythm: sweep smoothly to ~58.5s mark, then jump on minute tick
            displayedSeconds = Double(newSec)
        }
        .onAppear {
            displayedSeconds = Double(time.seconds)
        }
    }
}

// MARK: - Swiss Lollipop Second Hand

private struct SwissSecondHandCanvas: View {
    let angle: Angle
    let r: CGFloat
    let center: CGPoint
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            let rad = angle.radians
            let tailLen = r * 0.22
            let handLen = r * 0.85
            let circleR  = r * 0.085

            // Compute lollipop circle center (sits at ~60% along the hand)
            let circleCenter = CGPoint(
                x: center.x + cos(rad) * (handLen * 0.60),
                y: center.y + sin(rad) * (handLen * 0.60)
            )

            // Thin shaft
            var shaft = Path()
            shaft.move(to: CGPoint(
                x: center.x - cos(rad) * tailLen,
                y: center.y - sin(rad) * tailLen
            ))
            shaft.addLine(to: CGPoint(
                x: center.x + cos(rad) * handLen,
                y: center.y + sin(rad) * handLen
            ))
            ctx.stroke(shaft, with: .color(color), lineWidth: 1.8)

            // Lollipop disc
            let disc = Path(ellipseIn: CGRect(
                x: circleCenter.x - circleR,
                y: circleCenter.y - circleR,
                width: circleR * 2,
                height: circleR * 2
            ))
            ctx.fill(disc, with: .color(color))
        }
    }
}
