import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    private let featureColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private let quickColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    topBar

                    HomeHeroWidget(
                        progress: viewModel.ritualProgress,
                        completed: viewModel.ritual.completedCount,
                        total: viewModel.ritual.steps.count,
                        onAddCourse: viewModel.goToCourseForm
                    )

                    HomeStreakWidget(
                        current: viewModel.currentStreak,
                        best: viewModel.maxStreak,
                        cells: viewModel.miniHeatmap,
                        onTap: viewModel.goToHeatmap
                    )

                    HomeMetricStripWidget(
                        courses: viewModel.stats.totalCourses,
                        done: viewModel.stats.completedCourses,
                        lessons: viewModel.stats.totalLessons,
                        minutes: viewModel.stats.totalMinutes,
                        onStats: viewModel.goToStatistics
                    )

                    ritualWidgets

                    featureWidgets

                    quickActions

                    if viewModel.courses.isEmpty {
                        EmptyStateView(
                            icon: "🎯",
                            title: "Build Your Ritual",
                            message: "Add a course with lessons to generate today's focused steps",
                            buttonTitle: "Add Course",
                            action: viewModel.goToCourseForm
                        )
                        .appCard()
                    }

                    Spacer(minLength: 28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .clearScrollBackground()
        }
        .screenContainer()
        .onAppear { viewModel.loadData() }
    }

    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColor.accent)
                Text("Home")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
            }
            Spacer()
            Button(action: viewModel.goToSettings) {
                IconBadge(systemName: "gearshape.fill", color: AppColor.textSecondary, size: 42)
            }
            .buttonStyle(.plain)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "GOOD MORNING"
        case 12..<17: return "GOOD AFTERNOON"
        case 17..<22: return "GOOD EVENING"
        default: return "NIGHT SESSION"
        }
    }

    private var ritualWidgets: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Today's Steps",
                accessory: "\(viewModel.ritual.completedCount)/\(max(viewModel.ritual.steps.count, 1))"
            )

            if viewModel.ritual.steps.isEmpty {
                HStack(spacing: 14) {
                    Image(HomeArt.ritual)
                        .resizable()
                        .interpolation(.medium)
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("No steps yet")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppColor.textPrimary)
                        Text("Incomplete courses become today's ritual targets.")
                            .font(.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCard(padding: 14, radius: 20)
            } else {
                ForEach(Array(viewModel.ritual.steps.enumerated()), id: \.element.id) { index, step in
                    HomeRitualStepWidget(
                        index: index + 1,
                        step: step,
                        onOpen: { viewModel.openStep(step) },
                        onFocus: { viewModel.startFocus(for: step) },
                        onComplete: { viewModel.completeRitualStep(step) }
                    )
                }
            }
        }
    }

    private var featureWidgets: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Widgets")

            LazyVGrid(columns: featureColumns, spacing: 12) {
                HomeFeatureWidget(
                    title: "Focus Session",
                    subtitle: "25/45 min + reflection",
                    imageName: HomeArt.focus,
                    accent: AppColor.accent,
                    action: viewModel.goToFocus
                )
                HomeFeatureWidget(
                    title: "Skill Path",
                    subtitle: "Courses as skill nodes",
                    imageName: HomeArt.skillPath,
                    accent: AppColor.accentSecondary,
                    action: viewModel.goToSkillPath
                )
                HomeFeatureWidget(
                    title: "Recall Map",
                    subtitle: "Streak & memory heat",
                    imageName: HomeArt.recall,
                    accent: AppColor.danger,
                    action: viewModel.goToHeatmap
                )
                HomeFeatureWidget(
                    title: "Statistics",
                    subtitle: "Progress snapshot",
                    imageName: HomeArt.stats,
                    accent: Color(hex: "E6A700"),
                    action: viewModel.goToStatistics
                )
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Actions")

            LazyVGrid(columns: quickColumns, spacing: 10) {
                HomeQuickActionWidget(
                    icon: "plus.circle.fill",
                    title: "New",
                    color: AppColor.success,
                    action: viewModel.goToCourseForm
                )
                HomeQuickActionWidget(
                    icon: "list.bullet.rectangle",
                    title: "Courses",
                    color: AppColor.accent,
                    action: viewModel.goToCourseList
                )
                HomeQuickActionWidget(
                    icon: "timer",
                    title: "Focus",
                    color: AppColor.accentSecondary,
                    action: viewModel.goToFocus
                )
            }
        }
    }
}
