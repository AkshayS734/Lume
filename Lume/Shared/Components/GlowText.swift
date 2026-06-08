//  Akshay Shukla
//  GlowText.swift
//  Lume
//
//  Text with configurable multi-layer glow — used by digital themes
//  to achieve neon, LED, and futuristic light bloom effects.
//

import SwiftUI

// MARK: - GlowText

/// Renders text with a layered radial glow effect.
/// Uses two shadow passes: tight inner bloom + wide outer atmosphere.
struct GlowText: View {
    let text: String
    var font: Font = .system(size: 72, weight: .ultraLight)
    var color: Color = .white
    var glowColor: Color? = nil      // nil = derives from color
    var innerRadius: CGFloat = 8
    var outerRadius: CGFloat = 24
    var glowIntensity: Double = 1.0  // 0 = no glow, 1 = full

    private var resolvedGlow: Color {
        (glowColor ?? color).opacity(0.35 * glowIntensity)
    }

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(color)
            .shadow(color: resolvedGlow, radius: innerRadius)
            .shadow(color: resolvedGlow, radius: outerRadius)
            .shadow(color: resolvedGlow.opacity(0.5), radius: outerRadius * 2)
    }
}

// MARK: - GlowModifier

/// Apply glow to any view via `.glow(color:radius:)` modifier.
struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let intensity: Double

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.4 * intensity), radius: radius * 0.5)
            .shadow(color: color.opacity(0.25 * intensity), radius: radius)
            .shadow(color: color.opacity(0.12 * intensity), radius: radius * 2)
    }
}

extension View {
    func glow(color: Color = .white, radius: CGFloat = 16, intensity: Double = 1.0) -> some View {
        modifier(GlowModifier(color: color, radius: radius, intensity: intensity))
    }
}

// MARK: - MonoDigit

/// Monospaced digit text with optional glow — common pattern in digital themes.
struct MonoDigit: View {
    let text: String
    var size: CGFloat = 72
    var weight: Font.Weight = .ultraLight
    var color: Color = .white
    var glowRadius: CGFloat = 0

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: weight, design: .monospaced))
            .monospacedDigit()
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .glow(color: color, radius: glowRadius)
    }
}
