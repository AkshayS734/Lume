//  Akshay Shukla
//  PreferencesManager.swift
//  Lume
//
//  Observable preferences model backed by UserDefaults via @AppStorage.
//  All UI and window layers observe this for live updates.
//

import SwiftUI
import Combine
import ServiceManagement

@MainActor
final class PreferencesManager: ObservableObject {
    
    static let shared = PreferencesManager()
    
    // MARK: - Display
    
    @AppStorage(AppConstants.Keys.use24HourFormat)
    var use24HourFormat: Bool = AppConstants.Defaults.use24HourFormat {
        willSet { objectWillChange.send() }
    }
    
    @AppStorage(AppConstants.Keys.showDate)
    var showDate: Bool = AppConstants.Defaults.showDate {
        willSet { objectWillChange.send() }
    }
    
    // MARK: - Appearance
    
    @AppStorage(AppConstants.Keys.clockOpacity)
    var clockOpacity: Double = AppConstants.Defaults.clockOpacity {
        willSet { objectWillChange.send() }
    }
    
    @AppStorage(AppConstants.Keys.fontSize)
    var fontSize: Double = AppConstants.Defaults.fontSize {
        willSet { objectWillChange.send() }
    }
    
    // MARK: - Position (persisted per-screen center-relative offset)
    
    @Published var positions: [String: CGPoint] = [:] {
        didSet {
            var dict: [String: [Double]] = [:]
            for (key, val) in positions {
                dict[key] = [Double(val.x), Double(val.y)]
            }
            UserDefaults.standard.set(dict, forKey: AppConstants.Keys.savedPositions)
        }
    }
    
    // MARK: - Behavior
    
    @AppStorage(AppConstants.Keys.isVisible)
    var isVisible: Bool = AppConstants.Defaults.isVisible {
        willSet { objectWillChange.send() }
    }
    
    /// Transient flag — not persisted. True while the user is dragging the clock.
    @Published var isRepositioning: Bool = false
    
    @AppStorage(AppConstants.Keys.launchAtLogin)
    var launchAtLogin: Bool = AppConstants.Defaults.launchAtLogin {
        didSet { updateLaunchAtLogin() }
    }
    
    // MARK: - Helpers
    
    /// Toggles clock visibility with a smooth fade.
    func toggleVisibility() {
        isVisible.toggle()
    }
    
    /// Registers baseline defaults to avoid AppStorage racing.
    func registerDefaults() {
        let defaults: [String: Any] = [
            AppConstants.Keys.use24HourFormat: AppConstants.Defaults.use24HourFormat,
            AppConstants.Keys.showDate: AppConstants.Defaults.showDate,
            AppConstants.Keys.clockOpacity: AppConstants.Defaults.clockOpacity,
            AppConstants.Keys.fontSize: AppConstants.Defaults.fontSize,
            AppConstants.Keys.isVisible: AppConstants.Defaults.isVisible,
            AppConstants.Keys.launchAtLogin: AppConstants.Defaults.launchAtLogin
        ]
        UserDefaults.standard.register(defaults: defaults)
    }
    
    /// Resets clock position to the center of all screens.
    func resetPosition() {
        for screen in NSScreen.screens {
            guard let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else { continue }
            let screenID = String(screenNumber)
            positions[screenID] = CGPoint(x: screen.frame.width / 2, y: screen.frame.height / 2)
        }
    }
    
    /// Registers / unregisters the app from Login Items via SMAppService.
    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Launch at login error: \(error.localizedDescription)")
        }
    }
    
    private init() {
        if let dict = UserDefaults.standard.dictionary(forKey: AppConstants.Keys.savedPositions) as? [String: [Double]] {
            var loaded: [String: CGPoint] = [:]
            for (key, val) in dict {
                if val.count == 2 {
                    loaded[key] = CGPoint(x: val[0], y: val[1])
                }
            }
            positions = loaded
        }
    }
}
