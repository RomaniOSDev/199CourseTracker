import Foundation
import Combine

@MainActor
final class LessonViewModel: ObservableObject {
    @Published var course: Course
    @Published var lesson: Lesson
    @Published var noteText = ""
    @Published var isLocked = false

    private let courseEngine: CourseEngine
    private let ritualEngine: RitualEngine
    private let coordinator: AppCoordinator

    var needsTeachBack: Bool {
        ritualEngine.needsTeachBack(course: course, lesson: lesson)
    }

    init(
        course: Course,
        lesson: Lesson,
        courseEngine: CourseEngine,
        ritualEngine: RitualEngine,
        coordinator: AppCoordinator
    ) {
        self.course = course
        self.lesson = lesson
        self.courseEngine = courseEngine
        self.ritualEngine = ritualEngine
        self.coordinator = coordinator
        self.noteText = lesson.note ?? ""
        refresh()
    }

    func refresh() {
        if let updatedCourse = courseEngine.getCourse(by: course.id) {
            course = updatedCourse
            if let updatedLesson = updatedCourse.lessons.first(where: { $0.id == lesson.id }) {
                lesson = updatedLesson
                noteText = updatedLesson.note ?? noteText
                isLocked = !ritualEngine.isLessonUnlocked(course: updatedCourse, lesson: updatedLesson)
            }
        }
    }

    func toggleCompletion() {
        guard !isLocked || lesson.isCompleted else { return }
        let wasCompleted = lesson.isCompleted
        courseEngine.toggleLessonCompletion(courseId: course.id, lessonId: lesson.id)
        refresh()
        if !wasCompleted && lesson.isCompleted {
            ritualEngine.logActivity(type: .lessonCompleted, courseId: course.id, lessonId: lesson.id)
            coordinator.navigateToTeachBack(course: course, lesson: lesson)
        }
    }

    func saveNote() {
        var updatedLesson = lesson
        updatedLesson.note = noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? nil
            : noteText

        var updatedCourse = course
        if let index = updatedCourse.lessons.firstIndex(where: { $0.id == lesson.id }) {
            updatedCourse.lessons[index] = updatedLesson
            courseEngine.updateCourse(updatedCourse)
            course = updatedCourse
            lesson = updatedLesson
        }
    }

    func startFocus() {
        coordinator.navigateToFocusSession(courseId: course.id, lessonId: lesson.id)
    }

    func goToTeachBack() {
        coordinator.navigateToTeachBack(course: course, lesson: lesson)
    }

    func goBack() {
        coordinator.pop()
    }
}
