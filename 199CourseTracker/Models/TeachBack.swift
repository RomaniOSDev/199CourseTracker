import Foundation

struct Flashcard: Identifiable, Codable, Hashable {
    let id: UUID
    var front: String
    var back: String
}

enum TeachBackMode: String, Codable, Hashable {
    case summary
    case flashcards
}

struct TeachBackRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let courseId: UUID
    let lessonId: UUID
    let mode: TeachBackMode
    let summary: String?
    let flashcards: [Flashcard]
    let createdAt: Date
}
