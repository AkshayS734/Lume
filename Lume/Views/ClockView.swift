//  Akshay Shukla
//  ClockView.swift
//  Lume
//
//  The main clock display rendered on the desktop.
//  Uses SF Pro ultralight for a premium, minimal aesthetic.
//  Animates digit transitions smoothly using content transitions.
//

import SwiftUI

struct ClockView: View {
    
    @ObservedObject var viewModel: ClockViewModel
    @ObservedObject var preferences: PreferencesManager
    let screenID: String
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Computed Style
    
    private var foregroundColor: Color {
        colorScheme == .dark
            ? .white
            : .black
    }
    
    private var glowColor: Color {
        colorScheme == .dark
            ? .white.opacity(0.15)
            : .black.opacity(0.08)
    }
    
    private var subtitleColor: Color {
        foregroundColor.opacity(0.55)
    }
    
    var body: some View {
        ZStack {
            // MARK: - Main Clock
            VStack(spacing: preferences.fontSize * 0.08) {
                timeDisplay
                
                if preferences.showDate {
                    dateDisplay
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .drawingGroup()
            .opacity(preferences.isVisible ? preferences.clockOpacity : 0)
            .animation(.easeInOut(duration: 0.5), value: preferences.isVisible)
            .animation(.easeInOut(duration: 0.3), value: preferences.clockOpacity)
            .position(
                x: preferences.positions[screenID]?.x ?? 500,
                y: preferences.positions[screenID]?.y ?? 500
            )
            
            // MARK: - Drag Overlay (only in repositioning mode)
            if preferences.isRepositioning {
                DragOverlayView(preferences: preferences, screenID: screenID)
                    .transition(.opacity)
            }
        }
        .accessibilityHidden(true)
        .animation(.easeInOut(duration: 0.2), value: preferences.isRepositioning)
    }
    
    // MARK: - Time
    
    private var timeDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            // Hours
            Text(viewModel.hours)
                .font(.system(size: preferences.fontSize, weight: .ultraLight, design: .default))
                .monospacedDigit()
                .contentTransition(.numericText())
            
            // Colon — subtle
            Text(":")
                .font(.system(size: preferences.fontSize * 0.9, weight: .ultraLight, design: .default))
                .opacity(0.6)
            
            // Minutes
            Text(viewModel.minutes)
                .font(.system(size: preferences.fontSize, weight: .ultraLight, design: .default))
                .monospacedDigit()
                .contentTransition(.numericText())
            
            // Seconds — smaller, sits flush after the minutes
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)
                Text(viewModel.seconds)
                    .font(.system(size: preferences.fontSize * 0.38, weight: .ultraLight, design: .default))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .foregroundStyle(foregroundColor.opacity(0.65))
                    .padding(.leading, 5)
                    .animation(.easeInOut(duration: 0.4), value: viewModel.seconds)
            }
            .frame(height: preferences.fontSize * 0.80) // align baseline with main digits
            
            // AM/PM for 12-hour format
            if !preferences.use24HourFormat && !viewModel.amPm.isEmpty {
                Text(" \(viewModel.amPm)")
                    .font(.system(size: preferences.fontSize * 0.25, weight: .light, design: .default))
                    .foregroundStyle(subtitleColor)
                    .padding(.leading, 4)
                    .contentTransition(.numericText())
            }
        }
        .foregroundStyle(foregroundColor)
        .shadow(color: glowColor, radius: 20, x: 0, y: 2)
        .shadow(color: glowColor, radius: 40, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.6), value: viewModel.hours)
        .animation(.easeInOut(duration: 0.6), value: viewModel.minutes)
        .animation(.easeInOut(duration: 0.6), value: viewModel.amPm)
    }
    
    // MARK: - Date
    
    private var dateDisplay: some View {
        Text(viewModel.dateString.uppercased())
            .font(.system(size: preferences.fontSize * 0.18, weight: .regular, design: .default))
            .kerning(preferences.fontSize * 0.06)
            .foregroundStyle(subtitleColor)
            .shadow(color: glowColor, radius: 10, x: 0, y: 1)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.6), value: viewModel.dateString)
    }
}

// MARK: - Drag Overlay View

/// Full-screen transparent overlay rendered in the same NSHostingView as ClockView.
/// Captures drag gestures to reposition the clock, then exits repositioning mode.
struct DragOverlayView: View {
    
    @ObservedObject var preferences: PreferencesManager
    let screenID: String
    
    var body: some View {
        Color.white.opacity(0.001) // Invisible but gesture-capturing
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        preferences.positions[screenID] = value.location
                    }
                    .onEnded { _ in
                        // Single drag endss repositioning mode
                        preferences.isRepositioning = false
                    }
            )
            .ignoresSafeArea()
            .overlay(alignment: .top) {
                // Visual repositioning hint — anchored near the top center
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
}
