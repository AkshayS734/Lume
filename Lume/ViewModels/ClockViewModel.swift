//  Akshay Shukla
//  ClockViewModel.swift
//  Lume
//
//  Observable time publisher — drives all clock themes.
//  Migrated from ObservableObject to @Observable (macOS 14 Sonoma).
//  Publishes a ClockTime snapshot each second, aligned to the second boundary.
//

import SwiftUI
import Observation
import AppKit

// MARK: - ClockViewModel

@Observable
@MainActor
final class ClockViewModel {

    // MARK: - State

    var clockTime: ClockTime = .now(is24Hour: true)

    // MARK: - Private

    private let preferences = PreferencesManager.shared
    /// Nonisolated box so deinit can invalidate without touching @MainActor state.
    private let timerBox = TimerBox()

    // MARK: - Init

    init() {
        tick()
        startTimer()
        registerSleepObservers()
    }

    nonisolated deinit {
        timerBox.invalidate()
    }

    // MARK: - Timer lifecycle

    private func startTimer() {
        // Align to the next whole second for clean digit transitions
        let now = Date()
        let nextSecond = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(nanosecond: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(1)

        let delay = nextSecond.timeIntervalSince(now)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.tick()
                let t = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    Task { @MainActor in self?.tick() }
                }
                RunLoop.main.add(t, forMode: .common)
                self.timerBox.set(t)
            }
        }
    }

    private func tick() {
        clockTime = .now(is24Hour: preferences.use24HourFormat)
    }

    // MARK: - Sleep / wake handling

    private func registerSleepObservers() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(suspend),
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(resume),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )
    }

    @objc private func suspend() {
        timerBox.invalidate()
    }

    @objc private func resume() {
        guard timerBox.isEmpty else { return }
        tick()
        startTimer()
    }
}

// MARK: - TimerBox

/// Thread-safe wrapper that lets a nonisolated deinit invalidate a Timer
/// without accessing @MainActor-isolated state.
private final class TimerBox: @unchecked Sendable {
    private var timer: Timer?
    private let lock = NSLock()

    func set(_ t: Timer) {
        lock.withLock { timer = t }
    }

    func invalidate() {
        lock.withLock {
            timer?.invalidate()
            timer = nil
        }
    }

    var isEmpty: Bool {
        lock.withLock { timer == nil }
    }
}

// MARK: - Convenience accessors (backwards compat for menu bar label)

extension ClockViewModel {
    var hours:   String { clockTime.hoursString }
    var minutes: String { clockTime.minutesString }
    var seconds: String { clockTime.secondsString }
    var amPm:    String { clockTime.amPm }
    var dateString: String { clockTime.dateString }
}
