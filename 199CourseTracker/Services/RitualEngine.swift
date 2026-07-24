import Foundation

final class RitualEngine {
    private let storageService: StorageServiceProtocol
    private let courseEngine: CourseEngine

    init(storageService: StorageServiceProtocol, courseEngine: CourseEngine) {
        self.storageService = storageService
        self.courseEngine = courseEngine
    }

    // MARK: - Reset

    func resetAllData() {
        storageService.delete(forKey: StorageKey.activityEvents)
        storageService.delete(forKey: StorageKey.dailyRituals)
        storageService.delete(forKey: StorageKey.focusSessions)
        storageService.delete(forKey: StorageKey.teachBacks)
        storageService.delete(forKey: StorageKey.skillPathNodes)
    }

    // MARK: - Activity & Streak

    func logActivity(
        type: ActivityType,
        courseId: UUID? = nil,
        lessonId: UUID? = nil,
        minutes: Int? = nil
    ) {
        let event = ActivityEvent(
            id: UUID(),
            dayKey: DateKeyFormatter.dayKey(),
            timestamp: Date(),
            type: type,
            courseId: courseId,
            lessonId: lessonId,
            minutes: minutes
        )
        storageService.append(event, forKey: StorageKey.activityEvents)
        courseEngine.refreshStreakStats(
            current: currentStreak(),
            max: maxStreak()
        )
    }

    func allActivityEvents() -> [ActivityEvent] {
        storageService.load(forKey: StorageKey.activityEvents)
    }

    /// Returns intensity (0...4) keyed by day for the last `weeks` weeks.
    func heatmapIntensity(weeks: Int = 12) -> [(day: Date, intensity: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let start = calendar.date(byAdding: .day, value: -(weeks * 7 - 1), to: today) else {
            return []
        }

        var counts: [String: Int] = [:]
        for event in allActivityEvents() {
            counts[event.dayKey, default: 0] += 1
        }

        var result: [(Date, Int)] = []
        var cursor = start
        while cursor <= today {
            let key = DateKeyFormatter.dayKey(for: cursor)
            let count = counts[key, default: 0]
            let intensity: Int
            switch count {
            case 0: intensity = 0
            case 1: intensity = 1
            case 2...3: intensity = 2
            case 4...6: intensity = 3
            default: intensity = 4
            }
            result.append((cursor, intensity))
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    func activityDaysSet() -> Set<String> {
        Set(allActivityEvents().map(\.dayKey))
    }

    func currentStreak() -> Int {
        let days = activityDaysSet()
        guard !days.isEmpty else { return 0 }

        let calendar = Calendar.current
        var streak = 0
        var cursor = calendar.startOfDay(for: Date())

        // Allow streak to continue if yesterday was active and today not yet
        if !days.contains(DateKeyFormatter.dayKey(for: cursor)) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor),
                  days.contains(DateKeyFormatter.dayKey(for: yesterday)) else {
                return 0
            }
            cursor = yesterday
        }

        while days.contains(DateKeyFormatter.dayKey(for: cursor)) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    func maxStreak() -> Int {
        let keys = activityDaysSet().compactMap(DateKeyFormatter.date(fromDayKey:)).sorted()
        guard !keys.isEmpty else { return 0 }

        let calendar = Calendar.current
        var best = 1
        var current = 1

        for index in 1..<keys.count {
            let previous = keys[index - 1]
            let day = keys[index]
            if let expected = calendar.date(byAdding: .day, value: 1, to: previous),
               calendar.isDate(expected, inSameDayAs: day) {
                current += 1
                best = max(best, current)
            } else {
                current = 1
            }
        }
        return max(best, currentStreak())
    }

    // MARK: - Today's Ritual

    func todaysRitual(forceRegenerate: Bool = false) -> DailyRitual {
        let todayKey = DateKeyFormatter.dayKey()
        var rituals: [DailyRitual] = storageService.load(forKey: StorageKey.dailyRituals)
        let hasActiveCourses = courseEngine.getCourses().contains { !$0.isCompleted }

        if !forceRegenerate, let existing = rituals.first(where: { $0.dayKey == todayKey }) {
            if !(existing.steps.isEmpty && hasActiveCourses) {
                return existing
            }
        }

        let generated = generateRitual(for: todayKey)
        rituals.removeAll { $0.dayKey == todayKey }
        rituals.append(generated)
        storageService.save(rituals, forKey: StorageKey.dailyRituals)
        return generated
    }

    func markRitualStepCompleted(_ stepId: UUID) {
        let todayKey = DateKeyFormatter.dayKey()
        var rituals: [DailyRitual] = storageService.load(forKey: StorageKey.dailyRituals)
        guard let ritualIndex = rituals.firstIndex(where: { $0.dayKey == todayKey }),
              let stepIndex = rituals[ritualIndex].steps.firstIndex(where: { $0.id == stepId }) else {
            return
        }

        rituals[ritualIndex].steps[stepIndex].isCompleted = true
        storageService.save(rituals, forKey: StorageKey.dailyRituals)

        let step = rituals[ritualIndex].steps[stepIndex]
        logActivity(type: .ritualStep, courseId: step.courseId, lessonId: step.lessonId)
    }

    private func generateRitual(for dayKey: String) -> DailyRitual {
        let courses = courseEngine.getCourses().filter { !$0.isCompleted }
        var candidates: [(RitualStep, Int)] = []

        for course in courses {
            let lessons = course.lessons.sorted { $0.order < $1.order }
            guard let nextLesson = lessons.first(where: { !$0.isCompleted && isLessonUnlocked(course: course, lesson: $0) })
                    ?? lessons.first(where: { !$0.isCompleted }) else {
                continue
            }

            let progressWeight = Int(course.progress * 10)
            let favoriteBonus = course.isFavorite ? 5 : 0
            let reason: String
            if course.progress > 0 {
                reason = "Continue where you left off"
            } else if course.isFavorite {
                reason = "Favorite course waiting"
            } else {
                reason = "Fresh focus target"
            }

            let step = RitualStep(
                id: UUID(),
                courseId: course.id,
                lessonId: nextLesson.id,
                courseTitle: course.title,
                lessonTitle: nextLesson.title,
                reason: reason,
                isCompleted: false
            )
            candidates.append((step, progressWeight + favoriteBonus + (nextLesson.duration ?? 0) / 10))
        }

        let selected = candidates
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map(\.0)

        return DailyRitual(dayKey: dayKey, steps: Array(selected))
    }

    // MARK: - Focus

    func saveFocusSession(_ session: FocusSessionRecord) {
        storageService.append(session, forKey: StorageKey.focusSessions)
        logActivity(
            type: .focusSession,
            courseId: session.courseId,
            lessonId: session.lessonId,
            minutes: max(1, session.actualSeconds / 60)
        )
    }

    func focusSessions() -> [FocusSessionRecord] {
        storageService.load(forKey: StorageKey.focusSessions)
    }

    // MARK: - Teach-Back unlock

    func teachBacks() -> [TeachBackRecord] {
        storageService.load(forKey: StorageKey.teachBacks)
    }

    func hasTeachBack(courseId: UUID, lessonId: UUID) -> Bool {
        teachBacks().contains { $0.courseId == courseId && $0.lessonId == lessonId }
    }

    func saveTeachBack(_ record: TeachBackRecord) {
        var items = teachBacks()
        items.removeAll { $0.courseId == record.courseId && $0.lessonId == record.lessonId }
        items.append(record)
        storageService.save(items, forKey: StorageKey.teachBacks)
        logActivity(type: .teachBack, courseId: record.courseId, lessonId: record.lessonId)
        if record.mode == .flashcards {
            logActivity(type: .flashcardReview, courseId: record.courseId, lessonId: record.lessonId)
        }
    }

    func isLessonUnlocked(course: Course, lesson: Lesson) -> Bool {
        let sorted = course.lessons.sorted { $0.order < $1.order }
        guard let index = sorted.firstIndex(where: { $0.id == lesson.id }) else { return false }
        if index == 0 { return true }

        let previous = sorted[index - 1]
        return previous.isCompleted && hasTeachBack(courseId: course.id, lessonId: previous.id)
    }

    func needsTeachBack(course: Course, lesson: Lesson) -> Bool {
        lesson.isCompleted && !hasTeachBack(courseId: course.id, lessonId: lesson.id)
    }

    // MARK: - Skill Path

    func skillPathBranches() -> [SkillPathBranch] {
        ensureSkillPathSeeded()
        let nodes: [SkillPathNode] = storageService.load(forKey: StorageKey.skillPathNodes)
        let roots = nodes.filter { $0.parentId == nil }.sorted { $0.sortOrder < $1.sortOrder }
        return roots.map { root in
            let children = nodes
                .filter { $0.parentId == root.id }
                .sorted { $0.sortOrder < $1.sortOrder }
            return SkillPathBranch(id: root.id, root: root, children: children)
        }
    }

    func addSkillNode(title: String, parentId: UUID?, linkedCourseId: UUID?) {
        var nodes: [SkillPathNode] = storageService.load(forKey: StorageKey.skillPathNodes)
        let siblings = nodes.filter { $0.parentId == parentId }
        let node = SkillPathNode(
            id: UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            detail: nil,
            parentId: parentId,
            linkedCourseId: linkedCourseId,
            sortOrder: (siblings.map(\.sortOrder).max() ?? -1) + 1
        )
        nodes.append(node)
        storageService.save(nodes, forKey: StorageKey.skillPathNodes)
    }

    func deleteSkillNode(_ nodeId: UUID) {
        var nodes: [SkillPathNode] = storageService.load(forKey: StorageKey.skillPathNodes)
        nodes.removeAll { $0.id == nodeId || $0.parentId == nodeId }
        storageService.save(nodes, forKey: StorageKey.skillPathNodes)
    }

    func rebuildSkillPathFromCourses() {
        storageService.delete(forKey: StorageKey.skillPathNodes)
        ensureSkillPathSeeded(force: true)
    }

    private func ensureSkillPathSeeded(force: Bool = false) {
        let existing: [SkillPathNode] = storageService.load(forKey: StorageKey.skillPathNodes)
        if !force && !existing.isEmpty { return }

        let courses = courseEngine.getCourses()
        guard !courses.isEmpty else {
            storageService.save([SkillPathNode](), forKey: StorageKey.skillPathNodes)
            return
        }

        var nodes: [SkillPathNode] = []
        let grouped = Dictionary(grouping: courses, by: \.category)

        for (index, category) in Category.allCases.enumerated() {
            guard let categoryCourses = grouped[category], !categoryCourses.isEmpty else { continue }
            let rootId = UUID()
            nodes.append(
                SkillPathNode(
                    id: rootId,
                    title: "\(category.icon) \(category.rawValue)",
                    detail: "Skill branch",
                    parentId: nil,
                    linkedCourseId: nil,
                    sortOrder: index
                )
            )

            for (courseIndex, course) in categoryCourses.sorted(by: { $0.createdAt < $1.createdAt }).enumerated() {
                nodes.append(
                    SkillPathNode(
                        id: UUID(),
                        title: course.title,
                        detail: course.platform.rawValue,
                        parentId: rootId,
                        linkedCourseId: course.id,
                        sortOrder: courseIndex
                    )
                )
            }
        }

        storageService.save(nodes, forKey: StorageKey.skillPathNodes)
    }
}
