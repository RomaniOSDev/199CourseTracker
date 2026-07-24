import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    init(viewModel: StatisticsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Insights",
                        title: "Statistics",
                        subtitle: "A clear snapshot of your learning volume."
                    )

                    LazyVGrid(columns: columns, spacing: 10) {
                        MetricCell(value: "\(viewModel.totalCourses)", label: "Courses", icon: "books.vertical.fill", color: AppColor.accent)
                        MetricCell(value: "\(viewModel.completedCourses)", label: "Completed", icon: "checkmark.seal.fill", color: AppColor.success)
                        MetricCell(value: "\(Int(viewModel.completionRate))%", label: "Course rate", icon: "chart.pie.fill", color: Color(hex: "E6A700"))
                        MetricCell(value: "\(viewModel.totalLessons)", label: "Lessons", icon: "list.bullet", color: AppColor.accentSecondary)
                        MetricCell(value: "\(viewModel.completedLessons)", label: "Finished lessons", icon: "checkmark.circle.fill", color: AppColor.success)
                        MetricCell(value: "\(Int(viewModel.lessonCompletionRate))%", label: "Lesson rate", icon: "chart.bar.fill", color: Color(hex: "E6A700"))
                        MetricCell(value: "\(viewModel.totalMinutes)", label: "Learning minutes", icon: "clock.fill", color: AppColor.danger)
                        MetricCell(value: "\(viewModel.stats.currentStreak)", label: "Current streak", icon: "flame.fill", color: AppColor.danger)
                    }

                    if let category = viewModel.favoriteCategory {
                        infoRow(title: "Top Category", value: "\(category.icon) \(category.rawValue)", color: AppColor.accent)
                    }

                    if let platform = viewModel.favoritePlatform {
                        infoRow(title: "Top Platform", value: platform.rawValue, color: AppColor.accentSecondary)
                    }

                    if !viewModel.categoryData.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "By Category")
                            ForEach(viewModel.categoryData, id: \.0) { category, count in
                                CategoryStatCell(
                                    category: category,
                                    count: count,
                                    total: viewModel.totalCourses
                                )
                            }
                        }
                        .appCard()
                    }

                    if !viewModel.platformData.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "By Platform")
                            ForEach(viewModel.platformData, id: \.0) { platform, count in
                                HStack {
                                    Circle()
                                        .fill(Color(hex: platform.color))
                                        .frame(width: 10, height: 10)
                                    Text(platform.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppColor.textPrimary)
                                    Spacer()
                                    Text("\(count)")
                                        .font(.headline)
                                        .foregroundStyle(Color(hex: platform.color))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .appCard()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
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
        .onAppear { viewModel.loadData() }
    }

    private func infoRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
        }
        .appCard(padding: 14)
    }
}

private struct CategoryStatCell: View {
    let category: Category
    let count: Int
    let total: Int

    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(category.icon)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(Color(hex: category.color).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(category.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary)
                ProgressBarView(progress: percentage, height: 6)
            }

            Text("\(count)")
                .font(.headline)
                .foregroundStyle(AppColor.accent)
        }
    }
}
