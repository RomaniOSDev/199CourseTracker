import Foundation
import Combine
import UIKit
import StoreKit

@MainActor
final class SettingsViewModel: ObservableObject {
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
    }

    func resetAllData() {
        courseEngine.resetAllData()
        ritualEngine.resetAllData()
        OnboardingViewModel.resetCompletedFlag()
        coordinator.popToRoot()
    }

    func replayOnboarding() {
        OnboardingViewModel.resetCompletedFlag()
        coordinator.popToRoot()
        NotificationCenter.default.post(name: .replayOnboarding, object: nil)
    }

    func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    func openPrivacyPolicy() {
        open(AppLink.privacyPolicy)
    }

    func openTermsOfUse() {
        open(AppLink.termsOfUse)
    }

    func goBack() {
        coordinator.pop()
    }

    private func open(_ link: AppLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }
}
