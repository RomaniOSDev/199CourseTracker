import Foundation

final class CourseEngine {
    private let storageService: StorageServiceProtocol

    init(storageService: StorageServiceProtocol = UserDefaultsStorageService()) {
        self.storageService = storageService
    }

    func getCourses() -> [Course] {
        storageService.load(forKey: StorageKey.courses)
    }

    func addCourse(_ course: Course) {
        storageService.append(course, forKey: StorageKey.courses)
        updateStats()
    }

    func updateCourse(_ course: Course) {
        storageService.update(course, forKey: StorageKey.courses)
        updateStats()
    }

    func deleteCourse(_ course: Course) {
        var courses = getCourses()
        courses.removeAll { $0.id == course.id }
        storageService.save(courses, forKey: StorageKey.courses)

        var notes = getNotes()
        notes.removeAll { $0.courseId == course.id }
        storageService.save(notes, forKey: StorageKey.notes)

        updateStats()
    }

    func getCourse(by id: UUID) -> Course? {
        getCourses().first { $0.id == id }
    }

    func toggleLessonCompletion(courseId: UUID, lessonId: UUID) {
        guard var course = getCourse(by: courseId) else { return }

        guard let index = course.lessons.firstIndex(where: { $0.id == lessonId }) else { return }
        course.lessons[index].isCompleted.toggle()

        let allCompleted = !course.lessons.isEmpty && course.lessons.allSatisfy(\.isCompleted)
        if allCompleted {
            course.isCompleted = true
            course.endDate = Date()
        } else {
            course.isCompleted = false
            course.endDate = nil
        }

        updateCourse(course)
    }

    func getNotes() -> [Note] {
        storageService.load(forKey: StorageKey.notes)
    }

    func addNote(_ note: Note) {
        storageService.append(note, forKey: StorageKey.notes)
    }

    func updateNote(_ note: Note) {
        storageService.update(note, forKey: StorageKey.notes)
    }

    func deleteNote(_ note: Note) {
        var notes = getNotes()
        notes.removeAll { $0.id == note.id }
        storageService.save(notes, forKey: StorageKey.notes)
    }

    func getNotes(for courseId: UUID) -> [Note] {
        getNotes().filter { $0.courseId == courseId }
    }

    func resetAllData() {
        storageService.delete(forKey: StorageKey.courses)
        storageService.delete(forKey: StorageKey.notes)
        storageService.delete(forKey: StorageKey.stats)
    }

    func updateStats(currentStreak: Int? = nil, maxStreak: Int? = nil) {
        let courses = getCourses()
        let existing = getStats()

        var categoryCounts: [Category: Int] = [:]
        var platformCounts: [Platform: Int] = [:]
        var totalMinutes = 0

        for course in courses {
            totalMinutes += course.lessons.reduce(0) { $0 + ($1.duration ?? 0) }
            categoryCounts[course.category, default: 0] += 1
            platformCounts[course.platform, default: 0] += 1
        }

        let stats = Stats(
            totalCourses: courses.count,
            completedCourses: courses.filter(\.isCompleted).count,
            totalLessons: courses.reduce(0) { $0 + $1.lessons.count },
            completedLessons: courses.reduce(0) { $0 + $1.completedLessons },
            totalMinutes: totalMinutes,
            favoriteCategory: categoryCounts.max(by: { $0.value < $1.value })?.key,
            favoritePlatform: platformCounts.max(by: { $0.value < $1.value })?.key,
            currentStreak: currentStreak ?? existing.currentStreak,
            maxStreak: maxStreak ?? existing.maxStreak
        )

        storageService.saveObject(stats, forKey: StorageKey.stats)
    }

    func refreshStreakStats(current: Int, max: Int) {
        updateStats(currentStreak: current, maxStreak: max)
    }

    func getStats() -> Stats {
        storageService.loadObject(forKey: StorageKey.stats) ?? .empty
    }
}
