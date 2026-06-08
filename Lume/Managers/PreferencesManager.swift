//  Akshay Shukla
//  PreferencesManager.swift
//  Lume
//
//  Observable preferences model backed by UserDefaults.
//  Migrated from ObservableObject/@AppStorage to @Observable (macOS 14 Sonoma).
//  @Observable provides granular, property-level observation — only views that
//  read a specific property re-render when it changes. No unnecessary refreshes.
//

import SwiftUI
import Combine
import ServiceManagement
import Observation

// MARK: - PreferencesManager

@Observable
@MainActor
final class PreferencesManager {

    static let shared = PreferencesManager()

    // MARK: - Display

    var use24HourFormat: Bool = true {
        didSet { UserDefaults.standard.set(use24HourFormat, forKey: Keys.use24HourFormat) }
    }

    var showDate: Bool = true {
        didSet { UserDefaults.standard.set(showDate, forKey: Keys.showDate) }
    }

    // MARK: - Appearance

    var clockOpacity: Double = 0.80 {
        didSet { UserDefaults.standard.set(clockOpacity, forKey: Keys.clockOpacity) }
    }

    var fontSize: Double = 72.0 {
        didSet { UserDefaults.standard.set(fontSize, forKey: Keys.fontSize) }
    }

    // MARK: - Position (per-screen, persisted)

    var positions: [String: CGPoint] = [:] {
        didSet { savePositions() }
    }

    // MARK: - Behavior

    var isVisible: Bool = true {
        didSet { UserDefaults.standard.set(isVisible, forKey: Keys.isVisible) }
    }

    /// Transient flag — not persisted. True while the user is dragging the clock.
    var isRepositioning: Bool = false

    var launchAtLogin: Bool = false {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin)
            updateLaunchAtLogin()
        }
    }

    // MARK: - Helpers

    func toggleVisibility() {
        isVisible.toggle()
    }

    func resetPosition() {
        for screen in NSScreen.screens {
            guard let screenNumber = screen.deviceDescription[
                NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else { continue }
            positions[String(screenNumber)] = CGPoint(
                x: screen.frame.width / 2,
                y: screen.frame.height / 2
            )
        }
    }

    // MARK: - Init

    private init() {
        registerDefaults()
        loadAll()
    }

    // MARK: - Persistence

    func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Keys.use24HourFormat: true,
            Keys.showDate: true,
            Keys.clockOpacity: 0.80,
            Keys.fontSize: 72.0,
            Keys.isVisible: true,
            Keys.launchAtLogin: false,
        ])
    }

    private func loadAll() {
        let ud = UserDefaults.standard
        use24HourFormat = ud.bool(forKey: Keys.use24HourFormat)
        showDate        = ud.bool(forKey: Keys.showDate)
        clockOpacity    = ud.double(forKey: Keys.clockOpacity)
        fontSize        = ud.double(forKey: Keys.fontSize)
        isVisible       = ud.bool(forKey: Keys.isVisible)
        launchAtLogin   = ud.bool(forKey: Keys.launchAtLogin)
        loadPositions()
    }

    private func loadPositions() {
        guard let dict = UserDefaults.standard.dictionary(forKey: Keys.savedPositions)
                as? [String: [Double]] else { return }
        var loaded: [String: CGPoint] = [:]
        for (key, val) in dict where val.count == 2 {
            loaded[key] = CGPoint(x: val[0], y: val[1])
        }
        positions = loaded
    }

    private func savePositions() {
        var dict: [String: [Double]] = [:]
        for (key, pt) in positions {
            dict[key] = [Double(pt.x), Double(pt.y)]
        }
        UserDefaults.standard.set(dict, forKey: Keys.savedPositions)
    }

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("[Lume] Launch at login error: \(error.localizedDescription)")
        }
    }

    // MARK: - Keys

    private enum Keys {
        static let use24HourFormat = "use24HourFormat"
        static let clockOpacity    = "clockOpacity"
        static let fontSize        = "fontSize"
        static let showDate        = "showDate"
        static let savedPositions  = "savedPositions"
        static let isVisible       = "isVisible"
        static let launchAtLogin   = "launchAtLogin"
    }
}
