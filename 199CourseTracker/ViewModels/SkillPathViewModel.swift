import Foundation
import Combine

@MainActor
final class SkillPathViewModel: ObservableObject {
    @Published var branches: [SkillPathBranch] = []
    @Published var courses: [Course] = []
    @Published var showAddSheet = false
    @Published var newNodeTitle = ""
    @Published var selectedParentId: UUID?
    @Published var selectedCourseId: UUID?

    private let courseEngine: CourseEngine
    private let ritualEngine: RitualEngine
    private let coordinator: AppCoordinator

    init(
        courseEngine: CourseEngine,
        ritualEngine: RitualEngine,
        coordinator: AppCoordinator
    ) {
        self.courseEngine = courseEngine
        self.ritualEngine = ritualEngine
        self.coordinator = coordinator
        loadData()
    }

    func loadData() {
        courses = courseEngine.getCourses()
        branches = ritualEngine.skillPathBranches()
    }

    func rebuildFromCourses() {
        ritualEngine.rebuildSkillPathFromCourses()
        loadData()
    }

    func addNode() {
        let title = newNodeTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        ritualEngine.addSkillNode(
            title: title,
            parentId: selectedParentId,
            linkedCourseId: selectedCourseId
        )
        newNodeTitle = ""
        selectedParentId = nil
        selectedCourseId = nil
        showAddSheet = false
        loadData()
    }

    func deleteNode(_ id: UUID) {
        ritualEngine.deleteSkillNode(id)
        loadData()
    }

    func openCourse(_ courseId: UUID) {
        guard let course = courseEngine.getCourse(by: courseId) else { return }
        coordinator.navigateToCourseDetail(course: course)
    }

    func goBack() {
        coordinator.pop()
    }
}
