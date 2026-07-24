import SwiftUI

enum HomeArt {
    static let ritual = "HomeRitualArt"
    static let focus = "HomeFocusArt"
    static let skillPath = "HomeSkillPathArt"
    static let recall = "HomeRecallArt"
    static let stats = "HomeStatsArt"
}

struct HomeHeroWidget: View {
    let progress: Double
    let completed: Int
    let total: Int
    let onAddCourse: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(HomeArt.ritual)
                .resizable()
                .interpolation(.medium)
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 196)
                .clipped()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.02),
                    Color.black.opacity(0.58)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                Text("TODAY")
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.85))

                Text("Your Learning Ritual")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(total == 0
                     ? "Add a course to unlock today's steps"
                     : "\(completed) of \(total) steps done")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))

                ProgressBarView(progress: progress, height: 8)
                    .frame(maxWidth: 200)

                if total == 0 {
                    Button(action: onAddCourse) {
                        Text("Add Course")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppColor.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppColor.card)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 2)
                }
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.55), AppColor.accent.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        }
        .depthShadow(.hero)
    }
}

struct HomeStreakWidget: View {
    let current: Int
    let best: Int
    let cells: [(day: Date, intensity: Int)]
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(HomeArt.recall)
                    .resizable()
                    .interpolation(.medium)
                    .scaledToFill()
                    .frame(width: 86, height: 86)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Recall Streak")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppColor.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    HStack(spacing: 16) {
                        streakStat("\(current)", "Current")
                        streakStat("\(best)", "Best")
                    }

                    HStack(spacing: 3) {
                        ForEach(Array(cells.suffix(14).enumerated()), id: \.offset) { _, cell in
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(intensityColor(cell.intensity))
                                .frame(maxWidth: .infinity)
                                .frame(height: 10)
                        }
                    }
                }
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppDepth.Surfaces.card)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(AppDepth.Strokes.card, lineWidth: 1)
            }
            .depthShadow(.card)
        }
        .buttonStyle(.plain)
    }

    private func streakStat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppColor.accent)
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    private func intensityColor(_ intensity: Int) -> Color {
        switch intensity {
        case 0: return AppColor.surface
        case 1: return AppColor.accent.opacity(0.25)
        case 2: return AppColor.accent.opacity(0.45)
        case 3: return AppColor.accent.opacity(0.7)
        default: return AppColor.accent
        }
    }
}

struct HomeMetricStripWidget: View {
    let courses: Int
    let done: Int
    let lessons: Int
    let minutes: Int
    let onStats: () -> Void

    var body: some View {
        Button(action: onStats) {
            HStack(spacing: 0) {
                metric("\(courses)", "Courses", AppColor.accent)
                divider
                metric("\(done)", "Done", AppColor.success)
                divider
                metric("\(lessons)", "Lessons", AppColor.accentSecondary)
                divider
                metric("\(minutes)", "Minutes", AppColor.danger)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppDepth.Surfaces.card)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppDepth.Strokes.card, lineWidth: 1)
            }
            .depthShadow(.card)
        }
        .buttonStyle(.plain)
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColor.accent.opacity(0.12))
            .frame(width: 1, height: 34)
    }

    private func metric(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct HomeFeatureWidget: View {
    let title: String
    let subtitle: String
    let imageName: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                Image(imageName)
                    .resizable()
                    .interpolation(.medium)
                    .scaledToFill()
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppColor.textPrimary)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [accent.opacity(0.18), AppColor.card],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), accent.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .depthShadow(.raised)
        }
        .buttonStyle(.plain)
    }
}

struct HomeQuickActionWidget: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                IconBadge(systemName: icon, color: color, size: 36)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppDepth.Surfaces.card)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppDepth.Strokes.card, lineWidth: 1)
            }
            .depthShadow(.card)
        }
        .buttonStyle(.plain)
    }
}

struct HomeRitualStepWidget: View {
    let index: Int
    let step: RitualStep
    let onOpen: () -> Void
    let onFocus: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: step.isCompleted
                                    ? [AppColor.success.opacity(0.25), AppColor.success.opacity(0.1)]
                                    : [AppColor.accent.opacity(0.25), AppColor.accent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                        .frame(width: 44, height: 44)

                    if step.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppColor.success)
                    } else {
                        Text("\(index)")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppColor.accent)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(step.lessonTitle)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(AppColor.textPrimary)
                        .strikethrough(step.isCompleted)
                    Text(step.courseTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.accent)
                    Text(step.reason)
                        .font(.caption2)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                Button(action: onOpen) {
                    Label("Open", systemImage: "book.fill")
                }
                .buttonStyle(PrimaryButtonStyle())

                Button(action: onFocus) {
                    Label("Focus", systemImage: "timer")
                }
                .buttonStyle(SecondaryButtonStyle())

                if !step.isCompleted {
                    Button(action: onComplete) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppColor.success)
                            .frame(width: 46, height: 46)
                            .background(
                                LinearGradient(
                                    colors: [AppColor.success.opacity(0.18), AppColor.success.opacity(0.08)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(AppColor.success.opacity(0.2), lineWidth: 1)
                            }
                    }
                }
            }
        }
        .appCard(padding: 14, radius: 20, level: .card)
        .opacity(step.isCompleted ? 0.78 : 1)
    }
}
