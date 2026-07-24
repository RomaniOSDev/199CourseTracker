import SwiftUI

struct MetricCell: View {
    let value: String
    let label: String
    var icon: String? = nil
    var color: Color = AppColor.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let icon {
                IconBadge(systemName: icon, color: color, size: 34)
            }
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(padding: 14, radius: 16, level: .raised)
    }
}

struct FeatureActionCell: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                IconBadge(systemName: icon, color: color, size: 40)
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppColor.textPrimary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCard(padding: 14, radius: 16, level: .raised)
        }
        .buttonStyle(.plain)
    }
}

struct RitualStepCell: View {
    let index: Int
    let step: RitualStep
    let onOpen: () -> Void
    let onFocus: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: step.isCompleted
                                    ? [AppColor.success.opacity(0.24), AppColor.success.opacity(0.1)]
                                    : [AppColor.accent.opacity(0.24), AppColor.accent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
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

                VStack(alignment: .leading, spacing: 4) {
                    Text(step.lessonTitle)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(AppColor.textPrimary)
                        .strikethrough(step.isCompleted)
                    Text(step.courseTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.accent)
                    Text(step.reason)
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                Button(action: onOpen) {
                    Label("Open", systemImage: "book.fill")
                }
                .buttonStyle(PrimaryButtonStyle(color: AppColor.accent))

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
                            .background(AppColor.success.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }
        }
        .appCard(level: .raised)
        .opacity(step.isCompleted ? 0.72 : 1)
    }
}

struct SettingCell: View {
    let icon: String
    let title: String
    let subtitle: String
    var iconColor: Color = AppColor.accent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                IconBadge(systemName: icon, color: iconColor, size: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColor.textSecondary)
            }
            .appCard(level: .raised)
        }
        .buttonStyle(.plain)
    }
}

struct NoteCell: View {
    let note: Note
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                IconBadge(systemName: "note.text", color: AppColor.accentSecondary, size: 38)
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(AppColor.textSecondary)
                }
                Spacer()
            }

            Text(note.content.isEmpty ? "No content" : note.content)
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(4)

            HStack(spacing: 10) {
                Button("Edit", action: onEdit)
                    .buttonStyle(SecondaryButtonStyle())
                Button("Delete", action: onDelete)
                    .buttonStyle(SecondaryButtonStyle(tint: AppColor.danger))
            }
        }
        .appCard(level: .raised)
    }
}
