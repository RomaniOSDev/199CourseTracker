import Foundation
import Combine

@MainActor
final class CourseListViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var searchText = ""
    @Published var selectedCategory: Category?
    @Published var selectedPlatform: Platform?
    @Published var showCompletedOnly = false

    private let courseEngine: CourseEngine
    private let coordinator: AppCoordinator
    private let filterCategory: Category?

    var filteredCourses: [Course] {
        var result = courses

        if let category = filterCategory {
            result = result.filter { $0.category == category }
        }

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if let platform = selectedPlatform {
            result = result.filter { $0.platform == platform }
        }

        if showCompletedOnly {
            result = result.filter(\.isCompleted)
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        return result.sorted { $0.createdAt > $1.createdAt }
    }

    init(
        category: Category? = nil,
        courseEngine: CourseEngine,
        coordinator: AppCoordinator
    ) {
        self.filterCategory = category
        self.courseEngine = courseEngine
        self.coordinator = coordinator
        loadCourses()
    }

    func loadCourses() {
        courses = courseEngine.getCourses()
    }

    func deleteCourse(_ course: Course) {
        courseEngine.deleteCourse(course)
        loadCourses()
    }

    func toggleFavorite(_ course: Course) {
        var updated = course
        updated.isFavorite.toggle()
        courseEngine.updateCourse(updated)
        loadCourses()
    }

    func goToCourseDetail(_ course: Course) {
        coordinator.navigateToCourseDetail(course: course)
    }

    func goToCourseForm() {
        coordinator.navigateToCourseForm()
    }

    func goBack() {
        coordinator.pop()
    }
}
