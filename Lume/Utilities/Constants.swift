//  Akshay Shukla
//  Constants.swift
//  Lume
//
//  Shared constants and UserDefaults keys.
//

import Foundation

enum AppConstants {
    static let appName = "Lume"
    
    // MARK: - UserDefaults Keys
    enum Keys {
        static let use24HourFormat = "use24HourFormat"
        static let clockOpacity = "clockOpacity"
        static let fontSize = "fontSize"
        static let showDate = "showDate"
        static let savedPositions = "savedPositions"
        static let isVisible = "isVisible"
        static let launchAtLogin = "launchAtLogin"
    }
    
    // MARK: - Defaults
    enum Defaults {
        static let use24HourFormat = true
        static let clockOpacity: Double = 0.80
        static let fontSize: Double = 72.0
        static let showDate = true
        static let isVisible = true
        static let launchAtLogin = false
    }
    
    // MARK: - Limits
    enum Limits {
        static let minFontSize: Double = 32.0
        static let maxFontSize: Double = 160.0
        static let minOpacity: Double = 0.2
        static let maxOpacity: Double = 1.0
    }
}
