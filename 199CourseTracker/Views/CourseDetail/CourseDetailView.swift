import SwiftUI

struct CourseDetailView: View {
    @StateObject private var viewModel: CourseDetailViewModel

    init(viewModel: CourseDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    progressCard
                    lessonsSection
                    actionsSection
                    Spacer(minLength: 28)
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.toggleFavorite) {
                    Image(systemName: viewModel.course.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.course.isFavorite ? AppColor.danger : AppColor.textSecondary)
                }
            }
        }
        .alert("Delete Course?", isPresented: $viewModel.showDeleteAlert) {
            Button("Delete", role: .destructive, action: viewModel.deleteCourse)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All lessons and notes will be removed.")
        }
        .alert("Lesson Locked", isPresented: $viewModel.lockedLessonAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Complete the previous lesson and finish its Teach-Back to unlock this one.")
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            ShareSheet(items: viewModel.shareItems) {
                viewModel.showShareSheet = false
            }
            .presentationDetents([.medium])
        }
        .onAppear { viewModel.refresh() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: viewModel.course.category.color).opacity(0.25),
                                    AppColor.accent.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    Text(viewModel.course.category.icon)
                        .font(.largeTitle)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.course.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    HStack(spacing: 8) {
                        PlatformBadgeView(platform: viewModel.course.platform)
                        CategoryBadgeView(category: viewModel.course.category)
                    }
                }
            }

            if let description = viewModel.course.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .appCard(level: .raised)
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progress")
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text("\(viewModel.progressPercentage)%")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColor.accent)
            }

            ProgressBarView(progress: viewModel.progress, height: 10)

            HStack {
                Label(
                    "\(viewModel.completedLessons)/\(viewModel.totalLessons) lessons",
                    systemImage: "list.bullet"
                )
                .font(.caption)
                .foregroundStyle(AppColor.textSecondary)

                Spacer()

                if viewModel.isCompleted {
                    Label("Completed", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.success)
                }
            }
        }
        .appCard(level: .raised)
    }

    private var lessonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Lessons",
                accessory: "Teach-Back unlock"
            )

            Text("Finish a lesson, then teach it back to unlock the next one.")
                .font(.caption)
                .foregroundStyle(AppColor.textSecondary)

            ForEach(viewModel.course.lessons.sorted(by: { $0.order < $1.order })) { lesson in
                LessonRowView(
                    lesson: lesson,
                    isLocked: !viewModel.isUnlocked(lesson),
                    needsTeachBack: viewModel.needsTeachBack(lesson),
                    showFocusHint: viewModel.isUnlocked(lesson) && !lesson.isCompleted,
                    onToggle: { viewModel.toggleLessonCompletion(lesson: lesson) },
                    onTap: { viewModel.goToLessonDetail(lesson: lesson) },
                    onTeachBack: { viewModel.goToTeachBack(lesson: lesson) },
                    onFocus: { viewModel.goToFocus(lesson: lesson) }
                )
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            SectionHeaderView(title: "Actions")

            Button {
                viewModel.goToNotes()
            } label: {
                Label("Course Notes", systemImage: "note.text")
            }
            .buttonStyle(PrimaryButtonStyle(color: AppColor.accentSecondary))

            if let firstOpen = viewModel.course.lessons
                .sorted(by: { $0.order < $1.order })
                .first(where: { viewModel.isUnlocked($0) && !$0.isCompleted }) {
                Button {
                    viewModel.goToFocus(lesson: firstOpen)
                } label: {
                    Label("Focus on Next Lesson", systemImage: "timer")
                }
                .buttonStyle(PrimaryButtonStyle())
            }

            HStack(spacing: 12) {
                Button {
                    viewModel.shareCourse()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(SecondaryButtonStyle())

                Button {
                    viewModel.goToEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .buttonStyle(SecondaryButtonStyle(tint: AppColor.textSecondary))
            }

            if viewModel.course.certificateDate == nil {
                Button {
                    viewModel.markCertificate()
                } label: {
                    Label("Mark Certificate", systemImage: "rosette")
                }
                .buttonStyle(PrimaryButtonStyle(color: AppColor.success))
            } else if let date = viewModel.course.certificateDate {
                Label(
                    "Certificate earned \(date.formatted(date: .abbreviated, time: .omitted))",
                    systemImage: "checkmark.seal.fill"
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.success)
                .frame(maxWidth: .infinity)
                .appCard(padding: 12)
            }

            Button {
                viewModel.showDeleteAlert = true
            } label: {
                Label("Delete Course", systemImage: "trash")
            }
            .buttonStyle(SecondaryButtonStyle(tint: AppColor.danger))
        }
    }
}
