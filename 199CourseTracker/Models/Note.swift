import Foundation

struct Note: Identifiable, Codable, Hashable {
    let id: UUID
    var courseId: UUID
    var lessonId: UUID?
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
}
