//  Akshay Shukla
//  ColorExtensions.swift
//  Lume
//
//  Color utilities: hex initializer, adaptive light/dark helpers,
//  and brightness checking used across themes and settings.
//

import SwiftUI
import AppKit

// MARK: - Hex Initializer

extension Color {

    /// Initialize a Color from a CSS-style hex string.
    /// Accepts: "#RRGGBB", "#RRGGBBAA", "RRGGBB", "RGB"
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b, a: Double
        switch cleaned.count {
        case 3: // RGB
            (r, g, b, a) = (
                Double((int >> 8) & 0xF) / 15,
                Double((int >> 4) & 0xF) / 15,
                Double(int & 0xF) / 15,
                1
            )
        case 6: // RRGGBB
            (r, g, b, a) = (
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8)  & 0xFF) / 255,
                Double(int         & 0xFF) / 255,
                1
            )
        case 8: // RRGGBBAA
            (r, g, b, a) = (
                Double((int >> 24) & 0xFF) / 255,
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8)  & 0xFF) / 255,
                Double(int         & 0xFF) / 255
            )
        default:
            (r, g, b, a) = (0, 0, 0, 1)
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    /// Convert to hex string (without alpha).
    var hexString: String {
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        let r = Int((nsColor.redComponent * 255).rounded())
        let g = Int((nsColor.greenComponent * 255).rounded())
        let b = Int((nsColor.blueComponent * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Brightness Helpers

extension Color {

    /// Returns whether the color is perceptually "dark" (luminance < 0.5).
    var isDark: Bool {
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        let luminance = 0.2126 * Double(nsColor.redComponent)
                      + 0.7152 * Double(nsColor.greenComponent)
                      + 0.0722 * Double(nsColor.blueComponent)
        return luminance < 0.5
    }

    /// Returns white or black, whichever has better contrast against this color.
    var contrastingForeground: Color {
        isDark ? .white : .black
    }
}

// MARK: - Named Palette (used by theme defaults)

extension Color {
    // Warm whites
    static let warmWhite      = Color(hex: "#F5F0E8")
    static let coolWhite      = Color(hex: "#E8EEF5")

    // Clock face accent palette
    static let clockGold      = Color(hex: "#C9A84C")
    static let clockSilver    = Color(hex: "#B0B8C4")
    static let clockRed       = Color(hex: "#E03030")
    static let clockGreen     = Color(hex: "#00FF41")   // terminal green
    static let clockAmber     = Color(hex: "#FF8C00")   // LED amber

    // Glassmorphism
    static let glassWhite     = Color.white.opacity(0.18)
    static let glassBorder    = Color.white.opacity(0.25)
}

// MARK: - CGPoint Distance (used in corner snapping)

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}

// MARK: - Date Timezone helper

extension Date {
    /// Returns the date "as seen" in a given timezone (no actual conversion — just for Calendar use).
    func converted(to timezone: TimeZone) -> Date { self }
}
