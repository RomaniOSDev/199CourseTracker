import SwiftUI

struct LessonRowView: View {
    let lesson: Lesson
    let isLocked: Bool
    let needsTeachBack: Bool
    var showFocusHint: Bool = false
    let onToggle: () -> Void
    let onTap: () -> Void
    let onTeachBack: () -> Void
    var onFocus: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        borderColor.opacity(0.18),
                                        borderColor.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 30, height: 30)
                        Circle()
                            .stroke(borderColor, lineWidth: 2)
                            .frame(width: 28, height: 28)
                        if lesson.isCompleted {
                            Circle()
                                .fill(AppColor.success)
                                .frame(width: 28, height: 28)
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                        } else if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(isLocked && !lesson.isCompleted)

                Button(action: onTap) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isLocked && !lesson.isCompleted ? AppColor.textSecondary : AppColor.textPrimary)
                            .strikethrough(lesson.isCompleted)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 8) {
                            if let duration = lesson.duration {
                                Label("\(duration) min", systemImage: "clock")
                            }
                            if isLocked && !lesson.isCompleted {
                                Label("Locked", systemImage: "lock.fill")
                                    .foregroundStyle(AppColor.danger)
                            } else if needsTeachBack {
                                Label("Teach-Back needed", systemImage: "person.wave.2")
                                    .foregroundStyle(AppColor.accentSecondary)
                            }
                        }
                        .font(.caption2)
                        .foregroundStyle(AppColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColor.textSecondary.opacity(0.7))
            }
            .padding(14)

            if needsTeachBack || (showFocusHint && !isLocked && !lesson.isCompleted) {
                Divider().padding(.leading, 54)

                HStack(spacing: 8) {
                    if needsTeachBack {
                        Button(action: onTeachBack) {
                            Label("Teach-Back", systemImage: "person.wave.2.fill")
                                .font(.caption.weight(.bold))
                        }
                        .buttonStyle(SecondaryButtonStyle(tint: AppColor.accentSecondary))
                    }

                    if showFocusHint, let onFocus, !isLocked, !lesson.isCompleted {
                        Button(action: onFocus) {
                            Label("Focus", systemImage: "timer")
                                .font(.caption.weight(.bold))
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
                .padding(.top, 8)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppDepth.Surfaces.card)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppDepth.Strokes.card, lineWidth: 1)
        }
        .depthShadow(.card)
        .opacity(isLocked && !lesson.isCompleted ? 0.78 : 1)
    }

    private var borderColor: Color {
        if lesson.isCompleted { return AppColor.success }
        if isLocked { return AppColor.textSecondary.opacity(0.4) }
        return AppColor.accent.opacity(0.55)
    }
}
