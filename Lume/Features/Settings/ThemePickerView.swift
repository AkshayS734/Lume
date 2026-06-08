//  Akshay Shukla
//  ThemePickerView.swift
//  Lume
//
//  Live-preview theme grid inside Settings → Themes tab.
//  Hovering a theme shows an instant live preview on the desktop.
//  Clicking activates the theme permanently.
//

import SwiftUI

// MARK: - ThemePickerView

struct ThemePickerView: View {

    @State private var engine = ThemeEngine.shared
    @State private var selectedCategory: ThemeCategory? = nil
    @State private var previewTime = ClockTime.now(is24Hour: true)
    @State private var previewTimer: Timer?

    private var displayedThemes: [AnyClockTheme] {
        if let cat = selectedCategory {
            return engine.allThemes.filter { $0.category == cat }
        }
        return engine.allThemes
    }

    var body: some View {
        VStack(spacing: 0) {
            // Category filter pills
            categoryFilter
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

            // Theme grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                    ForEach(displayedThemes) { theme in
                        ThemeCard(
                            theme: theme,
                            isActive: engine.activeThemeID == theme.id,
                            previewTime: previewTime,
                            engine: engine
                        )
                    }
                }
                .padding(16)
            }
        }
        .onAppear { startPreviewTimer() }
        .onDisappear { stopPreviewTimer() }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        HStack(spacing: 8) {
            categoryPill(label: "All", category: nil)
            ForEach(ThemeCategory.allCases) { cat in
                categoryPill(label: cat.rawValue, category: cat)
            }
        }
    }

    private func categoryPill(label: String, category: ThemeCategory?) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            Text(label)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color.accentColor.opacity(0.2)
                        : Color.secondary.opacity(0.1),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Preview Timer

    private func startPreviewTimer() {
        previewTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            previewTime = .now(is24Hour: PreferencesManager.shared.use24HourFormat)
        }
        RunLoop.main.add(previewTimer!, forMode: .common)
    }

    private func stopPreviewTimer() {
        previewTimer?.invalidate()
        previewTimer = nil
        engine.endPreview()
    }
}

// MARK: - Theme Card

private struct ThemeCard: View {

    let theme: AnyClockTheme
    let isActive: Bool
    let previewTime: ClockTime
    let engine: ThemeEngine

    @State private var isHovered = false

    private var borderColor: Color {
        isActive ? .accentColor : (isHovered ? .secondary.opacity(0.5) : .clear)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Preview thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)

                // Render a scaled-down clock preview
                theme.makeView(
                    time: previewTime,
                    prefs: ThemePreferences(
                        accentColor: .white,
                        secondaryColor: .white.opacity(0.6),
                        scale: 0.3
                    )
                )
                .frame(width: 120, height: 80)
                .clipped()
                .allowsHitTesting(false)

                // Premium badge
                if theme.isPremium {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.yellow)
                                .padding(6)
                                .background(.black.opacity(0.5), in: Circle())
                                .padding(6)
                        }
                        Spacer()
                    }
                }
            }
            .frame(width: 140, height: 90)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: isActive ? 2 : 1)
            )
            .scaleEffect(isHovered ? 1.03 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)

            // Theme name
            HStack(spacing: 4) {
                Text(theme.displayName)
                    .font(.system(size: 11, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? Color.accentColor : Color.primary)
                    .lineLimit(1)

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                engine.beginPreview(of: theme.id)
            } else {
                engine.endPreview()
            }
        }
        .onTapGesture {
            engine.selectTheme(theme.id)
        }
    }
}
