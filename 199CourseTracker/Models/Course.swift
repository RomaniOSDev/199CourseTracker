import Foundation

struct Course: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String?
    var platform: Platform
    var category: Category
    var lessons: [Lesson]
    var startDate: Date?
    var endDate: Date?
    var certificateDate: Date?
    var isFavorite: Bool
    var isCompleted: Bool
    var createdAt: Date

    var totalLessons: Int {
        lessons.count
    }

    var completedLessons: Int {
        lessons.filter { $0.isCompleted }.count
    }

    var progress: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }

    var progressPercentage: Int {
        Int(progress * 100)
    }
}
