//  Akshay Shukla
//  ClockThemeID.swift
//  Lume
//
//  Enum registry for every clock theme in the app.
//  Adding a new theme = add a case here + implement ClockTheme + register in ThemeRegistry.
//

import Foundation

// MARK: - Theme Category

enum ThemeCategory: String, CaseIterable, Identifiable {
    case analog   = "Analog"
    case digital  = "Digital"
    case special  = "Special"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .analog:  return "clock"
        case .digital: return "digitalclock"
        case .special: return "sparkles"
        }
    }
}

// MARK: - Theme ID

enum ClockThemeID: String, CaseIterable, Identifiable, Codable {

    // MARK: Analog
    case minimalAnalog   = "minimal_analog"
    case swissRailway    = "swiss_railway"
    case classicWall     = "classic_wall"
    case luxuryWatch     = "luxury_watch"
    case glassmorphism   = "glassmorphism"
    case neumorphism     = "neumorphism"

    // MARK: Digital
    case minimalDigital  = "minimal_digital"
    case led             = "led"
    case flip            = "flip"
    case terminal        = "terminal"
    case dotMatrix       = "dot_matrix"
    case pixel           = "pixel"

    // MARK: Special
    case binary          = "binary"
    case word            = "word"
    case circularProgress = "circular_progress"
    case futuristic      = "futuristic"

    // MARK: - Identifiable
    var id: String { rawValue }

    // MARK: - Metadata

    var displayName: String {
        switch self {
        case .minimalAnalog:    return "Minimal"
        case .swissRailway:     return "Swiss Railway"
        case .classicWall:      return "Classic Wall"
        case .luxuryWatch:      return "Luxury Watch"
        case .glassmorphism:    return "Glassmorphism"
        case .neumorphism:      return "Neumorphism"
        case .minimalDigital:   return "Minimal Digital"
        case .led:              return "LED"
        case .flip:             return "Flip"
        case .terminal:         return "Terminal"
        case .dotMatrix:        return "Dot Matrix"
        case .pixel:            return "Pixel"
        case .binary:           return "Binary"
        case .word:             return "Word Clock"
        case .circularProgress: return "Circular Progress"
        case .futuristic:       return "Futuristic"
        }
    }

    var category: ThemeCategory {
        switch self {
        case .minimalAnalog, .swissRailway, .classicWall,
             .luxuryWatch, .glassmorphism, .neumorphism:
            return .analog
        case .minimalDigital, .led, .flip, .terminal, .dotMatrix, .pixel:
            return .digital
        case .binary, .word, .circularProgress, .futuristic:
            return .special
        }
    }

    /// Themes marked premium are gated behind PremiumGate in the UI.
    /// With Option A monetization, LumeStore always returns unlocked.
    var isPremium: Bool {
        switch self {
        case .luxuryWatch, .flip, .dotMatrix, .pixel, .word, .futuristic:
            return true
        default:
            return false
        }
    }

    /// SF Symbol used for theme preview placeholder and picker grid.
    var previewSymbol: String {
        switch self {
        case .minimalAnalog, .swissRailway, .classicWall,
             .luxuryWatch, .glassmorphism, .neumorphism:
            return "clock"
        case .minimalDigital, .led:
            return "digitalclock"
        case .flip:
            return "rectangle.split.2x1"
        case .terminal:
            return "terminal"
        case .dotMatrix:
            return "circle.grid.3x3"
        case .pixel:
            return "squareshape.split.2x2"
        case .binary:
            return "number.circle"
        case .word:
            return "textformat.abc"
        case .circularProgress:
            return "clock.arrow.circlepath"
        case .futuristic:
            return "sparkle"
        }
    }

    // MARK: - Grouped access

    static var byCategory: [ThemeCategory: [ClockThemeID]] {
        Dictionary(grouping: allCases) { $0.category }
    }
}

// MARK: - Premium Feature IDs

/// Used by PremiumGate to check unlock status.
/// With Option A, LumeStore.isUnlocked() always returns true.
enum PremiumFeatureID: String {
    // Premium themes
    case luxuryWatch
    case flipClock
    case dotMatrix
    case pixelClock
    case wordClock
    case futuristic

    // Premium feature bundles
    case worldClockUnlimited   // > 3 cities
    case weatherWidget
    case calendarIntegration
    case pomodoroStats

    /// App Store product ID mapping (for future StoreKit 2 wiring).
    var productID: String {
        switch self {
        case .luxuryWatch, .flipClock, .dotMatrix,
             .pixelClock, .wordClock, .futuristic:
            return "com.lume.premium.themes"
        default:
            return "com.lume.pro.annual"
        }
    }
}
