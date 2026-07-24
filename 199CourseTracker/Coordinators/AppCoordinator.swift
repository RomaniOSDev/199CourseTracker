import SwiftUI
import Combine

enum AppDestination: Hashable {
    case courseList(category: Category?)
    case courseForm(course: Course?)
    case courseDetail(course: Course)
    case lessonDetail(course: Course, lesson: Lesson)
    case notes(course: Course)
    case statistics
    case settings
    case focusSession(courseId: UUID?, lessonId: UUID?)
    case teachBack(course: Course, lesson: Lesson)
    case recallHeatmap
    case skillPath
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    let courseEngine: CourseEngine
    let ritualEngine: RitualEngine

    init(courseEngine: CourseEngine? = nil, ritualEngine: RitualEngine? = nil) {
        let storage = UserDefaultsStorageService()
        let courses = courseEngine ?? CourseEngine(storageService: storage)
        self.courseEngine = courses
        self.ritualEngine = ritualEngine ?? RitualEngine(storageService: storage, courseEngine: courses)
    }

    func navigateToCourseList(category: Category? = nil) {
        path.append(AppDestination.courseList(category: category))
    }

    func navigateToCourseForm(course: Course? = nil) {
        path.append(AppDestination.courseForm(course: course))
    }

    func navigateToCourseDetail(course: Course) {
        path.append(AppDestination.courseDetail(course: course))
    }

    func navigateToLessonDetail(course: Course, lesson: Lesson) {
        path.append(AppDestination.lessonDetail(course: course, lesson: lesson))
    }

    func navigateToNotes(course: Course) {
        path.append(AppDestination.notes(course: course))
    }

    func navigateToStatistics() {
        path.append(AppDestination.statistics)
    }

    func navigateToSettings() {
        path.append(AppDestination.settings)
    }

    func navigateToFocusSession(courseId: UUID? = nil, lessonId: UUID? = nil) {
        path.append(AppDestination.focusSession(courseId: courseId, lessonId: lessonId))
    }

    func navigateToTeachBack(course: Course, lesson: Lesson) {
        path.append(AppDestination.teachBack(course: course, lesson: lesson))
    }

    func navigateToRecallHeatmap() {
        path.append(AppDestination.recallHeatmap)
    }

    func navigateToSkillPath() {
        path.append(AppDestination.skillPath)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    @ViewBuilder
    func destination(for destination: AppDestination) -> some View {
        switch destination {
        case .courseList(let category):
            CourseListView(viewModel: CourseListViewModel(
                category: category,
                courseEngine: courseEngine,
                coordinator: self
            ))
        case .courseForm(let course):
            CourseFormView(viewModel: CourseFormViewModel(
                course: course,
                courseEngine: courseEngine,
                coordinator: self
            ))
        case .courseDetail(let course):
            CourseDetailView(viewModel: CourseDetailViewModel(
                course: course,
                courseEngine: courseEngine,
                ritualEngine: ritualEngine,
                coordinator: self
            ))
        case .lessonDetail(let course, let lesson):
            LessonDetailView(viewModel: LessonViewModel(
                course: course,
                lesson: lesson,
                courseEngine: courseEngine,
                ritualEngine: ritualEngine,
                coordinator: self
            ))
        case .notes(let course):
            NotesView(viewModel: NoteViewModel(
                course: course,
                courseEngine: courseEngine,
                coordinator: self
            ))
        case .statistics:
            StatisticsView(viewModel: StatisticsViewModel(
                courseEngine: courseEngine,
                coordinator: self
            ))
        case .settings:
            SettingsView(viewModel: SettingsViewModel(
                courseEngine: courseEngine,
                ritualEngine: ritualEngine,
                coordinator: self
            ))
        case .focusSession(let courseId, let lessonId):
            FocusSessionView(viewModel: FocusSessionViewModel(
                initialCourseId: courseId,
                initialLessonId: lessonId,
                courseEngine: courseEngine,
                ritualEngine: ritualEngine,
                coordinator: self
            ))
        case .teachBack(let course, let lesson):
            TeachBackView(viewModel: TeachBackViewModel(
                course: course,
                lesson: lesson,
                ritualEngine: ritualEngine,
                coordinator: self
            ))
        case .recallHeatmap:
            RecallHeatmapView(viewModel: RecallHeatmapViewModel(
                ritualEngine: ritualEngine,
                coordinator: self
            ))
        case .skillPath:
            SkillPathView(viewModel: SkillPathViewModel(
                courseEngine: courseEngine,
                ritualEngine: ritualEngine,
                coordinator: self
            ))
        }
    }
}
