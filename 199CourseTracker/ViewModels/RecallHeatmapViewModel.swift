import Foundation
import Combine

@MainActor
final class RecallHeatmapViewModel: ObservableObject {
    @Published var cells: [(day: Date, intensity: Int)] = []
    @Published var currentStreak = 0
    @Published var maxStreak = 0
    @Published var activeDays = 0
    @Published var totalEvents = 0

    private let ritualEngine: RitualEngine
    private let coordinator: AppCoordinator

    init(ritualEngine: RitualEngine, coordinator: AppCoordinator) {
        self.ritualEngine = ritualEngine
        self.coordinator = coordinator
        loadData()
    }

    func loadData() {
        cells = ritualEngine.heatmapIntensity(weeks: 12)
        currentStreak = ritualEngine.currentStreak()
        maxStreak = ritualEngine.maxStreak()
        activeDays = ritualEngine.activityDaysSet().count
        totalEvents = ritualEngine.allActivityEvents().count
    }

    func goBack() {
        coordinator.pop()
    }
}
