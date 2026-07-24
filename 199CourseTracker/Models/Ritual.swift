import Foundation

struct RitualStep: Identifiable, Codable, Hashable {
    let id: UUID
    let courseId: UUID
    let lessonId: UUID
    let courseTitle: String
    let lessonTitle: String
    let reason: String
    var isCompleted: Bool
}

struct DailyRitual: Codable, Hashable {
    let dayKey: String
    var steps: [RitualStep]

    var completedCount: Int { steps.filter(\.isCompleted).count }
    var isFullyComplete: Bool { !steps.isEmpty && steps.allSatisfy(\.isCompleted) }
}
