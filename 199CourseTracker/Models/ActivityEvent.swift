import Foundation

enum ActivityType: String, Codable, Hashable {
    case ritualStep
    case focusSession
    case lessonCompleted
    case teachBack
    case flashcardReview
}

struct ActivityEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let dayKey: String
    let timestamp: Date
    let type: ActivityType
    let courseId: UUID?
    let lessonId: UUID?
    let minutes: Int?
}
