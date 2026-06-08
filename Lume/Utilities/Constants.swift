//  Akshay Shukla
//  Constants.swift
//  Lume
//
//  Shared constants. UserDefaults keys have migrated into
//  PreferencesManager.Keys — this file now holds global app-level constants.
//

import Foundation

enum AppConstants {
    static let appName        = "Lume"
    static let bundleID       = "com.akshay.Lume"
    static let appVersion     = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

    // MARK: - Limits

    enum Limits {
        static let minFontSize: Double  = 32.0
        static let maxFontSize: Double  = 160.0
        static let minOpacity:  Double  = 0.20
        static let maxOpacity:  Double  = 1.0
        static let maxWorldClockCities  = 8    // free tier limit (Option A: ignored)
        static let pomodoroHistoryDays  = 30   // days to retain Pomodoro stats
    }

    // MARK: - Defaults

    enum Defaults {
        static let fontSize:   Double  = 72.0
        static let opacity:    Double  = 0.80
        static let is24Hour:   Bool    = true
        static let showDate:   Bool    = true
        static let isVisible:  Bool    = true
        static let launchAtLogin: Bool = false
    }

    // MARK: - Notification identifiers

    enum Notifications {
        static let pomodoroWorkEnd  = "com.lume.pomodoro.workEnd"
        static let pomodoroBreakEnd = "com.lume.pomodoro.breakEnd"
        static let timerComplete    = "com.lume.timer.complete"
        static let countdownAlert   = "com.lume.countdown.alert"
    }

    // MARK: - URL Schemes

    enum URLSchemes {
        static let lume = "lume://"
    }
}
