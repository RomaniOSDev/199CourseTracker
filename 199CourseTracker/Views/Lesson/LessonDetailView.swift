import SwiftUI

struct LessonDetailView: View {
    @StateObject private var viewModel: LessonViewModel

    init(viewModel: LessonViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    headerCard
                    actionRow
                    noteCard
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
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
        .onAppear { viewModel.refresh() }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.lesson.title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    Text(viewModel.course.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.accent)

                    HStack(spacing: 10) {
                        if let duration = viewModel.lesson.duration {
                            Label("\(duration) min", systemImage: "clock")
                        }
                        Label(
                            viewModel.lesson.isCompleted ? "Completed" : "In progress",
                            systemImage: viewModel.lesson.isCompleted ? "checkmark.seal.fill" : "circle"
                        )
                        .foregroundStyle(viewModel.lesson.isCompleted ? AppColor.success : AppColor.textSecondary)
                    }
                    .font(.caption)
                    .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                Button(action: viewModel.toggleCompletion) {
                    IconBadge(
                        systemName: viewModel.lesson.isCompleted ? "checkmark.circle.fill" : "circle",
                        color: viewModel.lesson.isCompleted ? AppColor.success : AppColor.accent,
                        size: 48
                    )
                }
                .disabled(viewModel.isLocked && !viewModel.lesson.isCompleted)
            }

            if viewModel.isLocked {
                Label("Locked until previous Teach-Back is done", systemImage: "lock.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColor.danger)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColor.danger.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .appCard()
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button(action: viewModel.startFocus) {
                Label("Focus", systemImage: "timer")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.isLocked)

            if viewModel.needsTeachBack {
                Button(action: viewModel.goToTeachBack) {
                    Label("Teach-Back", systemImage: "person.wave.2")
                }
                .buttonStyle(PrimaryButtonStyle(color: AppColor.accentSecondary))
            }
        }
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Lesson Note")

            TextEditor(text: $viewModel.noteText)
                .frame(minHeight: 160)
                .padding(12)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .foregroundStyle(AppColor.textPrimary)
                .scrollContentBackground(.hidden)

            Button(action: viewModel.saveNote) {
                Label("Save Note", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .appCard()
    }
}
