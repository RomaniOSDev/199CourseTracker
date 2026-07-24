import SwiftUI

struct CourseCardView: View {
    let course: Course
    var onFavorite: (() -> Void)? = nil
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: course.category.color).opacity(0.22),
                                        AppColor.accent.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                        Text(course.category.icon)
                            .font(.title2)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(course.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppColor.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 6) {
                            PlatformBadgeView(platform: course.platform)
                            CategoryBadgeView(category: course.category)
                        }
                    }

                    Spacer(minLength: 0)

                    VStack(spacing: 8) {
                        if let onFavorite {
                            Button {
                                onFavorite()
                            } label: {
                                Image(systemName: course.isFavorite ? "heart.fill" : "heart")
                                    .foregroundStyle(course.isFavorite ? AppColor.danger : AppColor.textSecondary)
                            }
                            .buttonStyle(.plain)
                        } else if course.isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(AppColor.danger)
                        }

                        if course.isCompleted {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(AppColor.success)
                        }
                    }
                }

                if let description = course.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                VStack(spacing: 8) {
                    HStack {
                        Text("\(course.progressPercentage)% complete")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColor.accent)
                        Spacer()
                        Text("\(course.completedLessons)/\(course.totalLessons) lessons")
                            .font(.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    ProgressBarView(progress: course.progress, height: 8)
                }

                HStack(spacing: 8) {
                    Label(course.platform.rawValue, systemImage: "laptopcomputer")
                    Spacer()
                    Text("Open")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .font(.caption)
                .foregroundStyle(AppColor.textSecondary)
            }
            .appCard(level: .raised)
        }
        .buttonStyle(.plain)
    }
}
