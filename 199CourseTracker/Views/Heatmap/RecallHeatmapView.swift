import SwiftUI

struct RecallHeatmapView: View {
    @StateObject private var viewModel: RecallHeatmapViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)

    init(viewModel: RecallHeatmapViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Memory",
                        title: "Recall Heatmap",
                        subtitle: "Only real activity fills this calendar."
                    )

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2),
                        spacing: 10
                    ) {
                        MetricCell(value: "\(viewModel.currentStreak)", label: "Current streak", icon: "flame.fill", color: AppColor.danger)
                        MetricCell(value: "\(viewModel.maxStreak)", label: "Best streak", icon: "trophy.fill", color: AppColor.accent)
                        MetricCell(value: "\(viewModel.activeDays)", label: "Active days", icon: "calendar", color: AppColor.accentSecondary)
                        MetricCell(value: "\(viewModel.totalEvents)", label: "Total events", icon: "bolt.fill", color: Color(hex: "E6A700"))
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeaderView(title: "Memory Calendar")

                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(Array(viewModel.cells.enumerated()), id: \.offset) { _, cell in
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(color(for: cell.intensity))
                                    .aspectRatio(1, contentMode: .fit)
                                    .overlay {
                                        if Calendar.current.isDateInToday(cell.day) {
                                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                                .stroke(AppColor.accentSecondary, lineWidth: 1.5)
                                        }
                                    }
                            }
                        }

                        HStack {
                            Text("Less")
                                .font(.caption2)
                                .foregroundStyle(AppColor.textSecondary)
                            ForEach(0..<5, id: \.self) { level in
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(color(for: level))
                                    .frame(width: 14, height: 14)
                            }
                            Text("More")
                                .font(.caption2)
                                .foregroundStyle(AppColor.textSecondary)
                            Spacer()
                        }
                    }
                    .appCard()
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
        .onAppear { viewModel.loadData() }
    }

    private func color(for intensity: Int) -> Color {
        switch intensity {
        case 0: return AppColor.surface.opacity(0.55)
        case 1: return AppColor.accent.opacity(0.25)
        case 2: return AppColor.accent.opacity(0.45)
        case 3: return AppColor.accent.opacity(0.7)
        default: return AppColor.accent
        }
    }
}
