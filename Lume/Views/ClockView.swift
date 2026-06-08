//  Akshay Shukla
//  ClockView.swift
//  Lume
//
//  Theme router — reads the active theme from ThemeEngine and renders it.
//  This view is the only one placed inside each desktop NSWindow.
//

import SwiftUI

// MARK: - ClockView (theme router)

struct ClockView: View {

    let viewModel: ClockViewModel
    let preferences: PreferencesManager
    let screenID: String

    @Environment(\.colorScheme) private var colorScheme

    // ThemeEngine drives which theme renders
    private var engine: ThemeEngine { ThemeEngine.shared }

    var body: some View {
        ZStack {
            // MARK: Active Clock Theme
            if preferences.isVisible {
                themeView
                    .opacity(preferences.clockOpacity)
                    .scaleEffect(preferences.fontSize / 72.0)
                    .position(
                        x: preferences.positions[screenID]?.x ?? 500,
                        y: preferences.positions[screenID]?.y ?? 500
                    )
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: preferences.isVisible)
                    .animation(.easeInOut(duration: 0.3), value: preferences.clockOpacity)
                    .animation(.easeInOut(duration: 0.3), value: preferences.fontSize)
            }

            // MARK: Drag Overlay (repositioning mode)
            if preferences.isRepositioning {
                DragOverlayView(preferences: preferences, screenID: screenID)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: preferences.isRepositioning)
    }

    // MARK: - Theme dispatch

    @ViewBuilder
    private var themeView: some View {
        let theme = engine.effectiveTheme
        let time  = viewModel.clockTime
        let prefs = adaptedPreferences

        theme.makeView(time: time, prefs: prefs)
            .id(engine.effectiveThemeID)   // force re-create view tree on theme switch
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: engine.effectiveThemeID)
    }

    // MARK: - Merge engine prefs with color scheme defaults

    private var adaptedPreferences: ThemePreferences {
        var p = engine.themePreferences
        // If user hasn't overridden accent, use adaptive color
        if p.accentColor == .white && colorScheme == .light {
            p.accentColor    = .black
            p.secondaryColor = .black.opacity(0.55)
        }
        p.scale = preferences.fontSize / 72.0
        p.reducedMotion = false  // overridden by @Environment in each theme
        return p
    }
}

// MARK: - DragOverlayView (moved to Shared/Components)

/// Full-screen transparent overlay for repositioning the clock by dragging.
struct DragOverlayView: View {

    let preferences: PreferencesManager
    let screenID: String

    var body: some View {
        Color.white.opacity(0.001)   // invisible but gesture-capturing
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        preferences.positions[screenID] = value.location
                    }
                    .onEnded { _ in
                        preferences.isRepositioning = false
                    }
            )
            .ignoresSafeArea()
            .overlay(alignment: .top) {
                repositioningHint
            }
    }

    private var repositioningHint: some View {
        VStack(spacing: 6) {
            Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                .font(.system(size: 18, weight: .light))
            Text("Drag to reposition")
                .font(.system(size: 13, weight: .medium))
            Text("Release to confirm")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 4)
        .padding(.top, 24)
    }
}
