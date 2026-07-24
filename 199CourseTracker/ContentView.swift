import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    @State private var showOnboarding = !OnboardingViewModel.hasCompleted

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showOnboarding = false
                    }
                }
                .transition(.opacity)
            } else {
                NavigationStack(path: $coordinator.path) {
                    HomeView(
                        viewModel: HomeViewModel(
                            courseEngine: coordinator.courseEngine,
                            ritualEngine: coordinator.ritualEngine,
                            coordinator: coordinator
                        )
                    )
                    .navigationDestination(for: AppDestination.self) { destination in
                        coordinator.destination(for: destination)
                    }
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .tint(AppColor.accent)
        .onReceive(NotificationCenter.default.publisher(for: .replayOnboarding)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                showOnboarding = true
            }
        }
    }
}

#Preview {
    ContentView()
}
