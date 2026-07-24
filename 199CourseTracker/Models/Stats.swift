import Foundation

struct Stats: Codable {
    var totalCourses: Int
    var completedCourses: Int
    var totalLessons: Int
    var completedLessons: Int
    var totalMinutes: Int
    var favoriteCategory: Category?
    var favoritePlatform: Platform?
    var currentStreak: Int
    var maxStreak: Int

    static let empty = Stats(
        totalCourses: 0,
        completedCourses: 0,
        totalLessons: 0,
        completedLessons: 0,
        totalMinutes: 0,
        favoriteCategory: nil,
        favoritePlatform: nil,
        currentStreak: 0,
        maxStreak: 0
    )
}
