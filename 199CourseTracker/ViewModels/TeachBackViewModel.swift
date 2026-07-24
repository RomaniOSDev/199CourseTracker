import Foundation
import Combine

@MainActor
final class TeachBackViewModel: ObservableObject {
    enum Mode: String, CaseIterable {
        case summary = "Summary"
        case flashcards = "Flashcards"
    }

    @Published var mode: Mode = .summary
    @Published var summaryText = ""
    @Published var cards: [FlashcardDraft] = [
        FlashcardDraft(),
        FlashcardDraft(),
        FlashcardDraft()
    ]

    let course: Course
    let lesson: Lesson

    private let ritualEngine: RitualEngine
    private let coordinator: AppCoordinator

    struct FlashcardDraft: Identifiable, Hashable {
        let id = UUID()
        var front = ""
        var back = ""

        var isValid: Bool {
            front.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 &&
            back.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
        }
    }

    var summaryValid: Bool {
        summaryText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 40
    }

    var flashcardsValid: Bool {
        cards.filter(\.isValid).count >= 3
    }

    var canSave: Bool {
        mode == .summary ? summaryValid : flashcardsValid
    }

    init(
        course: Course,
        lesson: Lesson,
        ritualEngine: RitualEngine,
        coordinator: AppCoordinator
    ) {
        self.course = course
        self.lesson = lesson
        self.ritualEngine = ritualEngine
        self.coordinator = coordinator
    }

    func save() {
        guard canSave else { return }

        let record: TeachBackRecord
        switch mode {
        case .summary:
            record = TeachBackRecord(
                id: UUID(),
                courseId: course.id,
                lessonId: lesson.id,
                mode: .summary,
                summary: summaryText.trimmingCharacters(in: .whitespacesAndNewlines),
                flashcards: [],
                createdAt: Date()
            )
        case .flashcards:
            let flashcards = cards.filter(\.isValid).prefix(3).map {
                Flashcard(
                    id: UUID(),
                    front: $0.front.trimmingCharacters(in: .whitespacesAndNewlines),
                    back: $0.back.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            record = TeachBackRecord(
                id: UUID(),
                courseId: course.id,
                lessonId: lesson.id,
                mode: .flashcards,
                summary: nil,
                flashcards: Array(flashcards),
                createdAt: Date()
            )
        }

        ritualEngine.saveTeachBack(record)
        coordinator.pop()
    }

    func goBack() {
        coordinator.pop()
    }
}
