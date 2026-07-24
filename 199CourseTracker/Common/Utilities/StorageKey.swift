import Foundation

enum StorageKey {
    static let courses = "courses"
    static let notes = "notes"
    static let stats = "stats"
    static let activityEvents = "activity_events"
    static let dailyRituals = "daily_rituals"
    static let focusSessions = "focus_sessions"
    static let teachBacks = "teach_backs"
    static let skillPathNodes = "skill_path_nodes"
    static let onboardingCompleted = "onboarding_completed"
}

enum DateKeyFormatter {
    static let day: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func dayKey(for date: Date = Date()) -> String {
        day.string(from: date)
    }

    static func date(fromDayKey key: String) -> Date? {
        day.date(from: key)
    }
}
