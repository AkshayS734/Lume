//  Akshay Shukla
//  ClockViewModel.swift
//  Lume
//
//  Drives the clock display — publishes formatted time & date strings,
//  updated every second on the second boundary for efficiency.
//

import SwiftUI
import Combine
import AppKit

@MainActor
final class ClockViewModel: ObservableObject {
    
    @Published var timeString: String = ""
    @Published var dateString: String = ""
    
    /// Separate hour/minute/second components for per-digit animation
    @Published var hours: String = ""
    @Published var minutes: String = ""
    @Published var seconds: String = ""
    @Published var amPm: String = ""
    
    private let preferences = PreferencesManager.shared
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // Formatters — cached for performance
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        return f
    }()
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        f.locale = Locale.current
        return f
    }()
    
    private let hourFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        return f
    }()
    
    private let minuteFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "mm"
        f.locale = Locale.current
        return f
    }()
    
    private let secondsFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "ss"
        f.locale = Locale.current
        return f
    }()
    
    private let amPmFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "a"
        f.locale = Locale.current
        return f
    }()
    
    init() {
        updateFormatters()
        tick()
        startTimer()
        
        // Re-create formatters when the user toggles 12/24h
        preferences.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.updateFormatters()
                self?.tick()
            }
            .store(in: &cancellables)
            
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(suspendTimer), name: NSWorkspace.screensDidSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(resumeTimer), name: NSWorkspace.screensDidWakeNotification, object: nil)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Timer
    
    @objc private func suspendTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func resumeTimer() {
        if timer == nil {
            tick()
            startTimer()
        }
    }
    
    private func startTimer() {
        // Align to the next whole second for clean transitions
        let now = Date()
        let nextSecond = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(nanosecond: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(1)
        
        let delay = nextSecond.timeIntervalSince(now)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.tick()
            self?.timer = Timer.scheduledTimer(
                withTimeInterval: 1.0,
                repeats: true
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.tick()
                }
            }
            // Ensure timer fires during UI tracking (scrolling, dragging)
            if let timer = self?.timer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
    
    /// Updates all published strings from the current time.
    private func tick() {
        let now = Date()
        timeString = timeFormatter.string(from: now)
        dateString = dateFormatter.string(from: now)
        hours = hourFormatter.string(from: now)
        minutes = minuteFormatter.string(from: now)
        seconds = secondsFormatter.string(from: now)
        
        if !preferences.use24HourFormat {
            amPm = amPmFormatter.string(from: now)
        } else {
            amPm = ""
        }
    }
    
    /// Reconfigures formatters when the user toggles format preference.
    private func updateFormatters() {
        if preferences.use24HourFormat {
            timeFormatter.dateFormat = "HH:mm"
            hourFormatter.dateFormat = "HH"
        } else {
            timeFormatter.dateFormat = "h:mm"
            hourFormatter.dateFormat = "h"
        }
    }
}
