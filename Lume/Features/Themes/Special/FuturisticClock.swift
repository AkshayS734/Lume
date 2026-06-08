//  Akshay Shukla
//  FuturisticClock.swift  [Premium]
//  Lume
//
//  Sci-fi HUD clock: rotating outer ring, segmented arcs,
//  glowing cyan digital readout with scan-line animation.
//

import SwiftUI

struct FuturisticClock: ClockTheme {
    let id: ClockThemeID = .futuristic

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(
            PremiumGate(feature: .futuristic) {
                FuturisticClockView(time: time, prefs: prefs)
            }
        )
    }
}

// MARK: - View

private struct FuturisticClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences

    @State private var outerRotation: Double = 0
    @State private var innerRotation: Double = 0
    @State private var scanLine: CGFloat = -1
    @State private var rotationTimer: Timer?

    private var hud: Color { prefs.accentColor == .white ? Color(hex: "#00E5FF") : prefs.accentColor }

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let r = d / 2

            ZStack {
                // Outer rotating dashes ring
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(hud.opacity(0.3),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 8]))
                    .frame(width: d, height: d)
                    .position(c)
                    .rotationEffect(.degrees(outerRotation))

                // Inner counter-rotating ring
                Circle()
                    .trim(from: 0.1, to: 0.6)
                    .stroke(hud.opacity(0.5),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: d * 0.85, height: d * 0.85)
                    .position(c)
                    .rotationEffect(.degrees(innerRotation))

                // Second arc (solid progress)
                Circle()
                    .trim(from: 0, to: Double(time.seconds) / 60.0)
                    .stroke(hud, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: d * 0.72, height: d * 0.72)
                    .position(c)
                    .animation(.linear(duration: 1), value: time.seconds)
                    .glow(color: hud, radius: 8, intensity: 0.9)

                // Corner hash marks
                Canvas { ctx, size in
                    for i in stride(from: 0, to: 360, by: 45) {
                        let angle = Double(i) * .pi / 180
                        let outer = CGPoint(
                            x: c.x + cos(angle) * r,
                            y: c.y + sin(angle) * r
                        )
                        let inner = CGPoint(
                            x: c.x + cos(angle) * (r * 0.88),
                            y: c.y + sin(angle) * (r * 0.88)
                        )
                        var p = Path(); p.move(to: outer); p.addLine(to: inner)
                        ctx.stroke(p, with: .color(hud.opacity(0.6)), lineWidth: 2)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // Center HUD display
                VStack(spacing: 6) {
                    Text("\(time.hoursString):\(time.minutesString):\(time.secondsString)")
                        .font(.system(size: d * 0.14, weight: .thin, design: .monospaced))
                        .foregroundStyle(hud)
                        .glow(color: hud, radius: 12, intensity: 0.9)
                        .contentTransition(.numericText())

                    Text(time.dateString.uppercased())
                        .font(.system(size: d * 0.06, weight: .light, design: .monospaced))
                        .foregroundStyle(hud.opacity(0.6))
                        .kerning(2)
                }
                .position(c)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
        .onAppear { startAnimations() }
        .onDisappear { stopAnimations() }
    }

    private func startAnimations() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            outerRotation = 360
        }
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
            innerRotation = -360
        }
    }

    private func stopAnimations() {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }
}
