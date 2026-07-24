import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showResetAlert = false

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Preferences",
                        title: "Settings",
                        subtitle: "Manage local data stored on this device."
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Legal & Feedback")

                        SettingCell(
                            icon: "star.fill",
                            title: "Rate Us",
                            subtitle: "Share feedback with a quick App Store review",
                            iconColor: Color(hex: "E6A700")
                        ) {
                            viewModel.rateApp()
                        }

                        SettingCell(
                            icon: "hand.raised.fill",
                            title: "Privacy Policy",
                            subtitle: "How your data is handled on this device",
                            iconColor: AppColor.accent
                        ) {
                            viewModel.openPrivacyPolicy()
                        }

                        SettingCell(
                            icon: "doc.text.fill",
                            title: "Terms of Use",
                            subtitle: "Rules and conditions for using the app",
                            iconColor: AppColor.accentSecondary
                        ) {
                            viewModel.openTermsOfUse()
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Data")

                        SettingCell(
                            icon: "trash.fill",
                            title: "Reset All Data",
                            subtitle: "Removes courses, notes, rituals, focus logs, and streaks",
                            iconColor: AppColor.danger
                        ) {
                            showResetAlert = true
                        }

                        SettingCell(
                            icon: "sparkles",
                            title: "Replay Onboarding",
                            subtitle: "Show the 3 intro screens again",
                            iconColor: AppColor.accentSecondary
                        ) {
                            viewModel.replayOnboarding()
                        }
                    }

                    Text("All learning data stays on this device. No accounts or cloud sync.")
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .clearScrollBackground()
        }
        .screenContainer()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: viewModel.goBack) {
                    Label("Back", systemImage: "chevron.left")
                        .foregroundStyle(AppColor.accent)
                }
            }
        }
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive, action: viewModel.resetAllData)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All courses, lessons, notes, rituals, and statistics will be deleted.")
        }
    }
}
