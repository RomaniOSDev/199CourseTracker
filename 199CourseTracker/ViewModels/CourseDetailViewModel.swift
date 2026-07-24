import Foundation
import Combine

@MainActor
final class CourseDetailViewModel: ObservableObject {
    @Published var course: Course
    @Published var showDeleteAlert = false
    @Published var shareItems: [Any] = []
    @Published var showShareSheet = false
    @Published var lockedLessonAlert = false

    private let courseEngine: CourseEngine
    private let ritualEngine: RitualEngine
    private let coordinator: AppCoordinator

    var progress: Double { course.progress }
    var progressPercentage: Int { course.progressPercentage }
    var totalLessons: Int { course.totalLessons }
    var completedLessons: Int { course.completedLessons }
    var isCompleted: Bool { course.isCompleted }

    init(
        course: Course,
        courseEngine: CourseEngine,
        ritualEngine: RitualEngine,
        coordinator: AppCoordinator
    ) {
        self.course = course
        self.courseEngine = courseEngine
        self.ritualEngine = ritualEngine
        self.coordinator = coordinator
        refresh()
    }

    func refresh() {
        if let updated = courseEngine.getCourse(by: course.id) {
            course = updated
        }
    }

    func isUnlocked(_ lesson: Lesson) -> Bool {
        ritualEngine.isLessonUnlocked(course: course, lesson: lesson)
    }

    func needsTeachBack(_ lesson: Lesson) -> Bool {
        ritualEngine.needsTeachBack(course: course, lesson: lesson)
    }

    func toggleLessonCompletion(lesson: Lesson) {
        guard isUnlocked(lesson) || lesson.isCompleted else {
            lockedLessonAlert = true
            return
        }

        let wasCompleted = lesson.isCompleted
        courseEngine.toggleLessonCompletion(courseId: course.id, lessonId: lesson.id)
        refresh()

        if !wasCompleted, let updated = course.lessons.first(where: { $0.id == lesson.id }), updated.isCompleted {
            ritualEngine.logActivity(type: .lessonCompleted, courseId: course.id, lessonId: lesson.id)
            coordinator.navigateToTeachBack(course: course, lesson: updated)
        }
    }

    func toggleFavorite() {
        var updated = course
        updated.isFavorite.toggle()
        courseEngine.updateCourse(updated)
        course = updated
    }

    func markCertificate() {
        var updated = course
        updated.certificateDate = Date()
        courseEngine.updateCourse(updated)
        course = updated
    }

    func deleteCourse() {
        courseEngine.deleteCourse(course)
        coordinator.pop()
    }

    func goToNotes() {
        coordinator.navigateToNotes(course: course)
    }

    func goToLessonDetail(lesson: Lesson) {
        if isUnlocked(lesson) {
            coordinator.navigateToLessonDetail(course: course, lesson: lesson)
            return
        }

        if let previous = course.lessons
            .sorted(by: { $0.order < $1.order })
            .last(where: { $0.order < lesson.order && needsTeachBack($0) }) {
            coordinator.navigateToTeachBack(course: course, lesson: previous)
        } else {
            lockedLessonAlert = true
        }
    }

    func goToTeachBack(lesson: Lesson) {
        coordinator.navigateToTeachBack(course: course, lesson: lesson)
    }

    func goToFocus(lesson: Lesson) {
        coordinator.navigateToFocusSession(courseId: course.id, lessonId: lesson.id)
    }

    func goToEdit() {
        coordinator.navigateToCourseForm(course: course)
    }

    func goBack() {
        coordinator.pop()
    }

    func shareCourse() {
        let text = """
        📚 \(course.title)
        📂 \(course.category.rawValue)
        🏷️ \(course.platform.rawValue)
        📊 Progress: \(progressPercentage)%
        📝 Lessons completed: \(completedLessons)/\(totalLessons)
        """
        shareItems = [text]
        showShareSheet = true
    }
}
