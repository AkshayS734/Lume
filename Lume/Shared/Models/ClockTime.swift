//  Akshay Shukla
//  ClockTime.swift
//  Lume
//
//  Immutable snapshot of the current time, passed into every clock theme.
//  Themes never need DateFormatters — they receive pre-computed values.
//

import Foundation

// MARK: - ClockTime

/// Passed to every ClockTheme.body(time:prefs:) call.
/// Computed fresh each second (or on sub-second tick for smooth analog sweep).
struct ClockTime: Equatable {

    // MARK: Components
    let hours: Int          // 0–23 always (themes handle 12/24h display)
    let minutes: Int        // 0–59
    let seconds: Int        // 0–59
    let milliseconds: Int   // 0–999 (for sub-second sweep on analog themes)

    // MARK: Formatted strings (pre-computed for digital themes)
    let hoursString: String     // "09" or "9" depending on is24Hour
    let minutesString: String   // "05"
    let secondsString: String   // "42"
    let amPm: String            // "AM" / "PM" or "" for 24h
    let dateString: String      // "Monday, June 8"

    // MARK: Format flag
    let is24Hour: Bool

    // MARK: Timezone
    let timezone: TimeZone

    // MARK: - Computed helpers

    var hours12: Int {
        let h = hours % 12
        return h == 0 ? 12 : h
    }

    var isPM: Bool { hours >= 12 }

    var fractionalSeconds: Double {
        Double(seconds) + Double(milliseconds) / 1000.0
    }

    var fractionalMinutes: Double {
        Double(minutes) + fractionalSeconds / 60.0
    }

    var fractionalHours: Double {
        Double(hours % 12) + fractionalMinutes / 60.0
    }

    /// Angle (in degrees) for the second hand, from 12 o'clock position.
    var secondHandAngle: Double { fractionalSeconds * 6.0 - 90.0 }

    /// Angle for the minute hand.
    var minuteHandAngle: Double { fractionalMinutes * 6.0 - 90.0 }

    /// Angle for the hour hand.
    var hourHandAngle: Double { fractionalHours * 30.0 - 90.0 }

    // MARK: - Factory

    static func now(is24Hour: Bool, timezone: TimeZone = .current) -> ClockTime {
        let date = Date()
        var cal = Calendar.current
        cal.timeZone = timezone

        let comps = cal.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        let h = comps.hour ?? 0
        let m = comps.minute ?? 0
        let s = comps.second ?? 0
        let ms = (comps.nanosecond ?? 0) / 1_000_000

        let hourStr: String
        if is24Hour {
            hourStr = String(format: "%02d", h)
        } else {
            let h12 = h % 12 == 0 ? 12 : h % 12
            hourStr = String(h12)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        dateFormatter.timeZone = timezone
        dateFormatter.locale = .current

        let amPmFormatter = DateFormatter()
        amPmFormatter.dateFormat = "a"
        amPmFormatter.timeZone = timezone
        amPmFormatter.locale = .current

        return ClockTime(
            hours: h,
            minutes: m,
            seconds: s,
            milliseconds: ms,
            hoursString: hourStr,
            minutesString: String(format: "%02d", m),
            secondsString: String(format: "%02d", s),
            amPm: is24Hour ? "" : amPmFormatter.string(from: date),
            dateString: dateFormatter.string(from: date),
            is24Hour: is24Hour,
            timezone: timezone
        )
    }
}
