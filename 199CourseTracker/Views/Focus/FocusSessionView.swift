import SwiftUI

struct FocusSessionView: View {
    @StateObject private var viewModel: FocusSessionViewModel

    init(viewModel: FocusSessionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            Group {
                switch viewModel.phase {
                case .setup:
                    setupPhase
                case .running:
                    runningPhase
                case .reflection:
                    reflectionPhase
                }
            }
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
    }

    private var setupPhase: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(
                    eyebrow: "Deep work",
                    title: "Focus Session",
                    subtitle: "One lesson. One timer. Honest reflection after."
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("Course")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.textSecondary)
                    Picker("Course", selection: $viewModel.selectedCourseId) {
                        Text("Select").tag(UUID?.none)
                        ForEach(viewModel.courses) { course in
                            Text(course.title).tag(Optional(course.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .onChange(of: viewModel.selectedCourseId) { _, _ in
                        viewModel.onCourseChanged()
                    }
                }
                .appCard()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Lesson")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.textSecondary)
                    Picker("Lesson", selection: $viewModel.selectedLessonId) {
                        Text("Select").tag(UUID?.none)
                        ForEach(viewModel.availableLessons) { lesson in
                            Text(lesson.title).tag(Optional(lesson.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .appCard()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Duration")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.textSecondary)
                    HStack(spacing: 12) {
                        durationChip(25)
                        durationChip(45)
                    }
                }
                .appCard()

                Button(action: viewModel.startSession) {
                    Label("Start Focus", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryButtonStyle(enabled: viewModel.canStart))
                .disabled(!viewModel.canStart)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .clearScrollBackground()
    }

    private var runningPhase: some View {
        VStack(spacing: 22) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppDepth.Surfaces.card)
                    .frame(width: 240, height: 240)
                    .depthShadow(.raised)

                Circle()
                    .stroke(AppColor.surface, lineWidth: 14)
                    .frame(width: 220, height: 220)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AppDepth.Surfaces.accent,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))

                Text(viewModel.timerDisplay)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
            }

            if let course = viewModel.selectedCourse,
               let lesson = viewModel.availableLessons.first(where: { $0.id == viewModel.selectedLessonId }) {
                VStack(spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(course.title)
                        .font(.subheadline)
                        .foregroundStyle(AppColor.accent)
                }
            }

            HStack(spacing: 12) {
                Button(viewModel.isRunning ? "Pause" : "Resume", action: viewModel.pauseOrResume)
                    .buttonStyle(SecondaryButtonStyle())
                Button("Finish", action: viewModel.finishEarly)
                    .buttonStyle(PrimaryButtonStyle(color: AppColor.accentSecondary))
            }
            .padding(.horizontal, 20)

            Text("Reflection is required to count this session.")
                .font(.caption)
                .foregroundStyle(AppColor.textSecondary)

            Spacer()
        }
    }

    private var reflectionPhase: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(
                    eyebrow: "Debrief",
                    title: "Session Reflection",
                    subtitle: "Answer all three prompts (min. 8 characters each)."
                )

                reflectionField("What did you learn?", $viewModel.whatLearned)
                reflectionField("What felt difficult?", $viewModel.whatWasHard)
                reflectionField("What is your next tiny step?", $viewModel.nextStep)

                Button(action: viewModel.saveReflection) {
                    Label("Save & Count Toward Streak", systemImage: "flame.fill")
                }
                .buttonStyle(PrimaryButtonStyle(enabled: viewModel.reflectionValid))
                .disabled(!viewModel.reflectionValid)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .clearScrollBackground()
    }

    private var progress: CGFloat {
        let total = CGFloat(viewModel.plannedMinutes * 60)
        guard total > 0 else { return 0 }
        return CGFloat(viewModel.plannedMinutes * 60 - viewModel.remainingSeconds) / total
    }

    private func durationChip(_ minutes: Int) -> some View {
        Button {
            viewModel.selectDuration(minutes)
        } label: {
            VStack(spacing: 6) {
                Text("\(minutes)")
                    .font(.title2.weight(.bold))
                Text("minutes")
                    .font(.caption)
            }
            .foregroundStyle(viewModel.plannedMinutes == minutes ? Color.white : AppColor.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background {
                if viewModel.plannedMinutes == minutes {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accent, AppColor.accentSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColor.surface)
                }
            }
        }
    }

    private func reflectionField(_ title: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.textSecondary)
            TextEditor(text: text)
                .frame(minHeight: 88)
                .padding(12)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .scrollContentBackground(.hidden)
        }
        .appCard(padding: 14)
    }
}
