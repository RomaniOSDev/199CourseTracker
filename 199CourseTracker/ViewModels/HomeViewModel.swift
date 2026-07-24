import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var stats: Stats
    @Published var ritual: DailyRitual
    @Published var currentStreak: Int = 0
    @Published var maxStreak: Int = 0
    @Published var miniHeatmap: [(day: Date, intensity: Int)] = []

    private let courseEngine: CourseEngine
    private let ritualEngine: RitualEngine
    private let coordinator: AppCoordinator

    var ritualProgress: Double {
        guard !ritual.steps.isEmpty else { return 0 }
        return Double(ritual.completedCount) / Double(ritual.steps.count)
    }

    init(
        courseEngine: CourseEngine,
        ritualEngine: RitualEngine,
        coordinator: AppCoordinator
    ) {
        self.courseEngine = courseEngine
        self.ritualEngine = ritualEngine
        self.coordinator = coordinator
        self.stats = courseEngine.getStats()
        self.ritual = DailyRitual(dayKey: DateKeyFormatter.dayKey(), steps: [])
        loadData()
    }

    func loadData() {
        courses = courseEngine.getCourses()
        stats = courseEngine.getStats()
        ritual = ritualEngine.todaysRitual()
        currentStreak = ritualEngine.currentStreak()
        maxStreak = ritualEngine.maxStreak()
        miniHeatmap = Array(ritualEngine.heatmapIntensity(weeks: 4).suffix(28))
        courseEngine.refreshStreakStats(current: currentStreak, max: maxStreak)
    }

    func completeRitualStep(_ step: RitualStep) {
        ritualEngine.markRitualStepCompleted(step.id)
        loadData()
    }

    func startFocus(for step: RitualStep) {
        coordinator.navigateToFocusSession(courseId: step.courseId, lessonId: step.lessonId)
    }

    func openStep(_ step: RitualStep) {
        guard let course = courseEngine.getCourse(by: step.courseId),
              let lesson = course.lessons.first(where: { $0.id == step.lessonId }) else {
            return
        }

        if ritualEngine.isLessonUnlocked(course: course, lesson: lesson) {
            coordinator.navigateToLessonDetail(course: course, lesson: lesson)
        } else if let previous = course.lessons.sorted(by: { $0.order < $1.order })
            .last(where: { $0.order < lesson.order && $0.isCompleted && ritualEngine.needsTeachBack(course: course, lesson: $0) }) {
            coordinator.navigateToTeachBack(course: course, lesson: previous)
        } else {
            coordinator.navigateToCourseDetail(course: course)
        }
    }

    func goToCourseList() { coordinator.navigateToCourseList() }
    func goToCourseForm() { coordinator.navigateToCourseForm() }
    func goToCourseDetail(_ course: Course) { coordinator.navigateToCourseDetail(course: course) }
    func goToStatistics() { coordinator.navigateToStatistics() }
    func goToSettings() { coordinator.navigateToSettings() }
    func goToFocus() { coordinator.navigateToFocusSession() }
    func goToHeatmap() { coordinator.navigateToRecallHeatmap() }
    func goToSkillPath() { coordinator.navigateToSkillPath() }
}
