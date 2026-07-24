import Foundation

struct FocusReflection: Codable, Hashable {
    var whatLearned: String
    var whatWasHard: String
    var nextStep: String

    var isValid: Bool {
        [whatLearned, whatWasHard, nextStep].allSatisfy {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= 8
        }
    }
}

struct FocusSessionRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let courseId: UUID
    let lessonId: UUID
    let plannedMinutes: Int
    let actualSeconds: Int
    let completedAt: Date
    let reflection: FocusReflection
}
