import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0

    let pages = OnboardingContent.pages

    var isLastPage: Bool {
        currentPage >= pages.count - 1
    }

    var progress: Double {
        guard pages.count > 1 else { return 1 }
        return Double(currentPage + 1) / Double(pages.count)
    }

    func next() {
        guard currentPage < pages.count - 1 else { return }
        currentPage += 1
    }

    func skipToEnd() {
        currentPage = max(pages.count - 1, 0)
    }

    func complete(onFinished: () -> Void) {
        UserDefaults.standard.set(true, forKey: StorageKey.onboardingCompleted)
        onFinished()
    }

    static var hasCompleted: Bool {
        UserDefaults.standard.bool(forKey: StorageKey.onboardingCompleted)
    }

    static func resetCompletedFlag() {
        UserDefaults.standard.removeObject(forKey: StorageKey.onboardingCompleted)
    }
}
