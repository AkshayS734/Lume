//  Akshay Shukla
//  TerminalClock.swift
//  Lume
//
//  Green-on-black terminal aesthetic with typewriter cursor blink.
//  Monospaced font, subtle scanline texture, classic hacker vibe.
//

import SwiftUI

struct TerminalClock: ClockTheme {
    let id: ClockThemeID = .terminal

    func makeView(time: ClockTime, prefs: ThemePreferences) -> AnyView {
        AnyView(TerminalClockView(time: time, prefs: prefs))
    }
}

// MARK: - View

private struct TerminalClockView: View {
    let time: ClockTime
    let prefs: ThemePreferences

    @State private var cursorVisible = true
    @State private var cursorTimer: Timer?

    // Terminal green — user accent overrides if they set a custom color
    private var terminalGreen: Color { prefs.accentColor == .white ? .clockGreen : prefs.accentColor }
    private var dimGreen: Color { terminalGreen.opacity(0.55) }
    private let baseSize: CGFloat = 52

    var body: some View {
        VStack(alignment: .leading, spacing: 4 * prefs.scale) {
            // Prompt line
            Text("$ lume --display now")
                .font(.system(size: baseSize * 0.28 * prefs.scale, weight: .regular, design: .monospaced))
                .foregroundStyle(dimGreen)

            // Main time + blinking cursor
            HStack(spacing: 0) {
                Text(timeString)
                    .font(.system(size: baseSize * prefs.scale, weight: .medium, design: .monospaced))
                    .foregroundStyle(terminalGreen)
                    .contentTransition(.numericText())
                    .glow(color: terminalGreen, radius: 8, intensity: 0.7)

                Rectangle()
                    .fill(terminalGreen)
                    .frame(width: baseSize * 0.55 * prefs.scale, height: baseSize * 0.90 * prefs.scale)
                    .opacity(cursorVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.1), value: cursorVisible)
                    .padding(.leading, 6 * prefs.scale)
            }

            // Date line
            Text(time.dateString.lowercased())
                .font(.system(size: baseSize * 0.26 * prefs.scale, weight: .regular, design: .monospaced))
                .foregroundStyle(dimGreen)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lumeTimeLabel(time))
        .onAppear { startCursor() }
        .onDisappear { stopCursor() }
    }

    private var timeString: String {
        String(format: "%@:%@:%@", time.hoursString, time.minutesString, time.secondsString)
    }

    private func startCursor() {
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.53, repeats: true) { _ in
            cursorVisible.toggle()
        }
        RunLoop.main.add(cursorTimer!, forMode: .common)
    }

    private func stopCursor() {
        cursorTimer?.invalidate()
        cursorTimer = nil
    }
}
