import SwiftUI

struct TeachBackView: View {
    @StateObject private var viewModel: TeachBackViewModel

    init(viewModel: TeachBackViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Unlock gate",
                        title: "Teach-Back",
                        subtitle: "Prove understanding to open the next lesson."
                    )

                    HStack(spacing: 12) {
                        IconBadge(systemName: "book.fill", color: AppColor.accent, size: 44)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.lesson.title)
                                .font(.headline)
                                .foregroundStyle(AppColor.textPrimary)
                            Text(viewModel.course.title)
                                .font(.caption)
                                .foregroundStyle(AppColor.accent)
                        }
                    }
                    .appCard()

                    Picker("Mode", selection: $viewModel.mode) {
                        ForEach(TeachBackViewModel.Mode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    if viewModel.mode == .summary {
                        summarySection
                    } else {
                        flashcardsSection
                    }

                    Button(action: viewModel.save) {
                        Label("Unlock Next Lesson", systemImage: "lock.open.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle(enabled: viewModel.canSave))
                    .disabled(!viewModel.canSave)
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
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Explain in your own words")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.textSecondary)
            TextEditor(text: $viewModel.summaryText)
                .frame(minHeight: 170)
                .padding(12)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .scrollContentBackground(.hidden)
            Text("\(viewModel.summaryText.trimmingCharacters(in: .whitespacesAndNewlines).count)/40 characters")
                .font(.caption2)
                .foregroundStyle(viewModel.summaryValid ? AppColor.success : AppColor.textSecondary)
        }
        .appCard()
    }

    private var flashcardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create 3 flashcards")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.textSecondary)

            ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, _ in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card \(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColor.accent)
                    TextField("Front (prompt)", text: $viewModel.cards[index].front)
                        .padding()
                        .background(AppColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    TextField("Back (answer)", text: $viewModel.cards[index].back)
                        .padding()
                        .background(AppColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .appCard(padding: 12)
            }
        }
    }
}
