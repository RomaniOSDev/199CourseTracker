import Foundation

struct Lesson: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var duration: Int?
    var isCompleted: Bool
    var order: Int
    var note: String?
}
