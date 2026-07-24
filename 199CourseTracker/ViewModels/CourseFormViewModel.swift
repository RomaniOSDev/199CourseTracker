import Foundation
import Combine

@MainActor
final class CourseFormViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var selectedPlatform: Platform = .other
    @Published var selectedCategory: Category = .other
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date().addingTimeInterval(30 * 24 * 60 * 60)
    @Published var isFavorite = false
    @Published var lessons: [Lesson] = []

    @Published var lessonTitle = ""
    @Published var lessonDuration = ""

    private let courseEngine: CourseEngine
    private let coordinator: AppCoordinator
    private let editingCourse: Course?

    var isEditing: Bool { editingCourse != nil }

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lessons.isEmpty
    }

    var lessonFormValid: Bool {
        !lessonTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        course: Course? = nil,
        courseEngine: CourseEngine,
        coordinator: AppCoordinator
    ) {
        self.editingCourse = course
        self.courseEngine = courseEngine
        self.coordinator = coordinator

        if let course {
            title = course.title
            description = course.description ?? ""
            selectedPlatform = course.platform
            selectedCategory = course.category
            startDate = course.startDate ?? Date()
            endDate = course.endDate ?? Date().addingTimeInterval(30 * 24 * 60 * 60)
            isFavorite = course.isFavorite
            lessons = course.lessons.sorted { $0.order < $1.order }
        }
    }

    func addLesson() {
        guard lessonFormValid else { return }

        let lesson = Lesson(
            id: UUID(),
            title: lessonTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            duration: Int(lessonDuration),
            isCompleted: false,
            order: lessons.count + 1,
            note: nil
        )
        lessons.append(lesson)
        lessonTitle = ""
        lessonDuration = ""
    }

    func removeLesson(_ lesson: Lesson) {
        lessons.removeAll { $0.id == lesson.id }
        for index in lessons.indices {
            lessons[index].order = index + 1
        }
    }

    func saveCourse() {
        guard isFormValid else { return }

        if isEditing, let course = editingCourse {
            var updated = course
            updated.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.description = description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : description.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.platform = selectedPlatform
            updated.category = selectedCategory
            updated.startDate = startDate
            updated.endDate = endDate
            updated.isFavorite = isFavorite
            updated.lessons = lessons
            courseEngine.updateCourse(updated)
        } else {
            let newCourse = Course(
                id: UUID(),
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? nil
                    : description.trimmingCharacters(in: .whitespacesAndNewlines),
                platform: selectedPlatform,
                category: selectedCategory,
                lessons: lessons,
                startDate: startDate,
                endDate: nil,
                certificateDate: nil,
                isFavorite: isFavorite,
                isCompleted: false,
                createdAt: Date()
            )
            courseEngine.addCourse(newCourse)
        }

        coordinator.pop()
    }

    func cancel() {
        coordinator.pop()
    }
}
