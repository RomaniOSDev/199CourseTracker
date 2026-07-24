import Foundation
import Combine

@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published var stats: Stats
    @Published var courses: [Course] = []
    @Published var categoryData: [(Category, Int)] = []
    @Published var platformData: [(Platform, Int)] = []

    private let courseEngine: CourseEngine
    private let coordinator: AppCoordinator

    var totalCourses: Int { stats.totalCourses }
    var completedCourses: Int { stats.completedCourses }
    var completionRate: Double {
        guard totalCourses > 0 else { return 0 }
        return Double(completedCourses) / Double(totalCourses) * 100
    }
    var totalLessons: Int { stats.totalLessons }
    var completedLessons: Int { stats.completedLessons }
    var lessonCompletionRate: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons) * 100
    }
    var totalMinutes: Int { stats.totalMinutes }
    var favoriteCategory: Category? { stats.favoriteCategory }
    var favoritePlatform: Platform? { stats.favoritePlatform }

    init(courseEngine: CourseEngine, coordinator: AppCoordinator) {
        self.courseEngine = courseEngine
        self.coordinator = coordinator
        self.stats = courseEngine.getStats()
        loadData()
    }

    func loadData() {
        courses = courseEngine.getCourses()
        stats = courseEngine.getStats()

        var categories: [Category: Int] = [:]
        var platforms: [Platform: Int] = [:]

        for course in courses {
            categories[course.category, default: 0] += 1
            platforms[course.platform, default: 0] += 1
        }

        categoryData = categories.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }
        platformData = platforms.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }
    }

    func goBack() {
        coordinator.pop()
    }
}
