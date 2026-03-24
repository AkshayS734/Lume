//  Akshay Shukla
//  AppDelegate.swift
//  Lume
//
//  Manages desktop-level NSWindows — one per display.
//  Each window is borderless, transparent, click-through, and pinned
//  to the desktop layer so the clock appears as part of the wallpaper.
//

import AppKit
import SwiftUI
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// One window per connected display.
    private var clockWindows: [NSWindow] = []
    
    /// Shared instances injected into each window's SwiftUI view.
    private let preferences = PreferencesManager.shared
    private let viewModel = ClockViewModel()
    
    /// Whether repositioning mode is active (mouse events temporarily enabled).
    /// Setting this updates both the preferences flag and the windows' mouse-event mode.
    var isRepositioning: Bool {
        get { preferences.isRepositioning }
        set {
            preferences.isRepositioning = newValue
            updateMouseEventHandling()
        }
    }
    
    /// Global keyboard shortcut monitor (⌘⇧W to toggle visibility).
    private var keyMonitor: Any?
    /// Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        preferences.registerDefaults()
        createClockWindows()
        registerKeyboardShortcut()
        
        // Watch preferences.isRepositioning so that when DragOverlayView
        // sets it to false directly, we still update ignoresMouseEvents on all windows.
        preferences.$isRepositioning
            .dropFirst()                 // skip the initial value
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateMouseEventHandling() }
            .store(in: &cancellables)
        
        // Observe display configuration changes (resolution, displays added/removed)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    // MARK: - Window Creation
    
    /// Creates one desktop-level window per connected screen.
    private func createClockWindows() {
        // Remove any existing windows
        clockWindows.forEach { $0.orderOut(nil) }
        clockWindows.removeAll()
        
        for screen in NSScreen.screens {
            let window = createDesktopWindow(for: screen)
            clockWindows.append(window)
        }
    }
    
    /// Configures a single NSWindow to sit at the desktop layer.
    private func createDesktopWindow(for screen: NSScreen) -> NSWindow {
        let screenID: String
        if let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID {
            screenID = String(screenNumber)
        } else {
            screenID = UUID().uuidString
        }
        
        if preferences.positions[screenID] == nil {
            preferences.positions[screenID] = CGPoint(x: screen.frame.width / 2, y: screen.frame.height / 2)
        }
        
        let window = DesktopWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false,
            screen: screen
        )
        
        // — Transparent, non-opaque, no shadow —
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        
        // — Desktop-level window layering —
        // kCGDesktopWindowLevel + 1 places us above the wallpaper but below
        // desktop icons (which live at kCGDesktopIconWindowLevel).
        // This is the sweet spot: the clock feels "painted on" the wallpaper.
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        
        // — Collection behavior —
        // .canJoinAllSpaces → visible on every Space / virtual desktop
        // .stationary       → stays in place during Space transitions
        // .ignoresCycle     → excluded from ⌘Tab and Mission Control
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        
        // — Click-through by default (no mouse interaction) —
        window.ignoresMouseEvents = true
        
        // — Prevent the window from becoming key or main —
        // This avoids stealing focus from other apps.
        window.canBecomeVisibleWithoutLogin = true
        
        // — SwiftUI content —
        let hostingView = NSHostingView(
            rootView: ClockView(viewModel: viewModel, preferences: preferences, screenID: screenID)
                .frame(width: screen.frame.width, height: screen.frame.height)
        )
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        window.contentView = hostingView
        window.orderFront(nil)
        
        return window
    }
    
    // MARK: - Repositioning
    
    /// Toggles repositioning mode. While active, the window accepts mouse events
    /// and ClockView renders the DragOverlayView inline (same NSHostingView — no subview nesting).
    func toggleRepositioning() {
        isRepositioning.toggle()
    }
    
    private func updateMouseEventHandling() {
        for window in clockWindows {
            if preferences.isRepositioning {
                // Accept mouse events so the drag gesture fires.
                window.ignoresMouseEvents = false
                // Raise to floating level (above all normal app windows)
                // so clicks actually reach our window.
                window.level = .floating
            } else {
                // Restore click-through desktop mode.
                window.ignoresMouseEvents = true
                window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
            }
        }
    }
    
    // MARK: - Screen Changes
    
    @objc private func screenParametersChanged() {
        // Recreate windows when screens change (resolution, display added/removed)
        createClockWindows()
    }
    
    // MARK: - Keyboard Shortcut
    
    /// Registers ⌘⇧W as a global hotkey to toggle visibility.
    private func registerKeyboardShortcut() {
        keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // ⌘⇧W
            guard event.modifierFlags.contains([.command, .shift]),
                  event.keyCode == 13 // 'W' key
            else { return }
            
            Task { @MainActor in
                self?.preferences.toggleVisibility()
            }
        }
    }
}



// MARK: - Non-Activating Window

/// Custom NSWindow subclass that never becomes the key window,
/// preventing focus theft from other apps.
final class DesktopWindow: NSWindow {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
