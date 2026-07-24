import Foundation
import Combine

@MainActor
final class FocusSessionViewModel: ObservableObject {
    enum Phase {
        case setup
        case running
        case reflection
    }

    @Published var phase: Phase = .setup
    @Published var courses: [Course] = []
    @Published var selectedCourseId: UUID?
    @Published var selectedLessonId: UUID?
    @Published var plannedMinutes: Int = 25
    @Published var remainingSeconds: Int = 25 * 60
    @Published var elapsedSeconds: Int = 0
    @Published var isRunning = false

    @Published var whatLearned = ""
    @Published var whatWasHard = ""
    @Published var nextStep = ""

    private var timerTask: Task<Void, Never>?
    private let courseEngine: CourseEngine
    private let ritualEngine: RitualEngine
    private let coordinator: AppCoordinator

    var selectedCourse: Course? {
        courses.first { $0.id == selectedCourseId }
    }

    var availableLessons: [Lesson] {
        guard let course = selectedCourse else { return [] }
        return course.lessons
            .sorted { $0.order < $1.order }
            .filter { ritualEngine.isLessonUnlocked(course: course, lesson: $0) || $0.isCompleted }
    }

    var canStart: Bool {
        selectedCourseId != nil && selectedLessonId != nil
    }

    var reflectionValid: Bool {
        FocusReflection(
            whatLearned: whatLearned,
            whatWasHard: whatWasHard,
            nextStep: nextStep
        ).isValid
    }

    var timerDisplay: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    init(
        initialCourseId: UUID?,
        initialLessonId: UUID?,
        courseEngine: CourseEngine,
        ritualEngine: RitualEngine,
        coordinator: AppCoordinator
    ) {
        self.courseEngine = courseEngine
        self.ritualEngine = ritualEngine
        self.coordinator = coordinator
        courses = courseEngine.getCourses()
        selectedCourseId = initialCourseId ?? courses.first?.id
        if let lessonId = initialLessonId {
            selectedLessonId = lessonId
        } else {
            selectedLessonId = availableLessons.first?.id
        }
        remainingSeconds = plannedMinutes * 60
    }

    func selectDuration(_ minutes: Int) {
        plannedMinutes = minutes
        remainingSeconds = minutes * 60
        elapsedSeconds = 0
    }

    func onCourseChanged() {
        selectedLessonId = availableLessons.first?.id
    }

    func startSession() {
        guard canStart else { return }
        phase = .running
        isRunning = true
        remainingSeconds = plannedMinutes * 60
        elapsedSeconds = 0
        startTicker()
    }

    func pauseOrResume() {
        isRunning.toggle()
        if isRunning {
            startTicker()
        } else {
            timerTask?.cancel()
            timerTask = nil
        }
    }

    func finishEarly() {
        timerTask?.cancel()
        timerTask = nil
        isRunning = false
        phase = .reflection
    }

    private func startTicker() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { break }
                await MainActor.run {
                    self.tick()
                }
            }
        }
    }

    private func tick() {
        guard isRunning else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            elapsedSeconds += 1
        } else {
            timerTask?.cancel()
            timerTask = nil
            isRunning = false
            phase = .reflection
        }
    }

    func saveReflection() {
        guard reflectionValid,
              let courseId = selectedCourseId,
              let lessonId = selectedLessonId else { return }

        let actual = max(elapsedSeconds, plannedMinutes * 60 - remainingSeconds)
        let session = FocusSessionRecord(
            id: UUID(),
            courseId: courseId,
            lessonId: lessonId,
            plannedMinutes: plannedMinutes,
            actualSeconds: actual,
            completedAt: Date(),
            reflection: FocusReflection(
                whatLearned: whatLearned.trimmingCharacters(in: .whitespacesAndNewlines),
                whatWasHard: whatWasHard.trimmingCharacters(in: .whitespacesAndNewlines),
                nextStep: nextStep.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        )
        ritualEngine.saveFocusSession(session)
        coordinator.pop()
    }

    func goBack() {
        timerTask?.cancel()
        timerTask = nil
        coordinator.pop()
    }
}
