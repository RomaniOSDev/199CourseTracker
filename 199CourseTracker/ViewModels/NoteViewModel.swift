import Foundation
import Combine

@MainActor
final class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var course: Course
    @Published var newNoteTitle = ""
    @Published var newNoteContent = ""
    @Published var editingNote: Note?

    private let courseEngine: CourseEngine
    private let coordinator: AppCoordinator

    init(
        course: Course,
        courseEngine: CourseEngine,
        coordinator: AppCoordinator
    ) {
        self.course = course
        self.courseEngine = courseEngine
        self.coordinator = coordinator
        loadNotes()
    }

    func loadNotes() {
        notes = courseEngine.getNotes(for: course.id).sorted { $0.updatedAt > $1.updatedAt }
    }

    func addNote(title: String, content: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let note = Note(
            id: UUID(),
            courseId: course.id,
            lessonId: nil,
            title: trimmedTitle,
            content: content,
            createdAt: Date(),
            updatedAt: Date()
        )
        courseEngine.addNote(note)
        loadNotes()
    }

    func updateNote(_ note: Note) {
        var updated = note
        updated.updatedAt = Date()
        courseEngine.updateNote(updated)
        loadNotes()
    }

    func deleteNote(_ note: Note) {
        courseEngine.deleteNote(note)
        loadNotes()
    }

    func goBack() {
        coordinator.pop()
    }
}
