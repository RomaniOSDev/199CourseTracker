import SwiftUI

struct CourseFormView: View {
    @StateObject private var viewModel: CourseFormViewModel
    @FocusState private var focusedField: Field?

    enum Field {
        case title, description, lessonTitle, lessonDuration
    }

    init(viewModel: CourseFormViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(
                        eyebrow: viewModel.isEditing ? "Edit" : "Create",
                        title: viewModel.isEditing ? "Edit Course" : "New Course",
                        subtitle: "Title and at least one lesson are required."
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        fieldBlock("Title *") {
                            TextField("Course title", text: $viewModel.title)
                                .padding()
                                .background(AppColor.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .focused($focusedField, equals: .title)
                        }

                        fieldBlock("Description") {
                            TextEditor(text: $viewModel.description)
                                .frame(minHeight: 90)
                                .padding(12)
                                .background(AppColor.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .scrollContentBackground(.hidden)
                                .focused($focusedField, equals: .description)
                        }
                    }
                    .appCard()

                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            fieldBlock("Platform") {
                                Picker("", selection: $viewModel.selectedPlatform) {
                                    ForEach(Platform.allCases, id: \.self) { platform in
                                        Text(platform.rawValue).tag(platform)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppColor.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }

                            fieldBlock("Category") {
                                Picker("", selection: $viewModel.selectedCategory) {
                                    ForEach(Category.allCases, id: \.self) { category in
                                        Text("\(category.icon) \(category.rawValue)").tag(category)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppColor.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }

                        HStack(spacing: 12) {
                            fieldBlock("Start Date") {
                                DatePicker("", selection: $viewModel.startDate, displayedComponents: [.date])
                                    .labelsHidden()
                                    .tint(AppColor.accent)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColor.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }

                            fieldBlock("End Date") {
                                DatePicker("", selection: $viewModel.endDate, displayedComponents: [.date])
                                    .labelsHidden()
                                    .tint(AppColor.accent)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColor.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }

                        Toggle("Add to Favorites", isOn: $viewModel.isFavorite)
                            .tint(AppColor.accent)
                    }
                    .appCard()

                    lessonsSection

                    Button(action: viewModel.saveCourse) {
                        Label(
                            viewModel.isEditing ? "Save Changes" : "Add Course",
                            systemImage: viewModel.isEditing ? "checkmark.circle.fill" : "plus.circle.fill"
                        )
                    }
                    .buttonStyle(PrimaryButtonStyle(enabled: viewModel.isFormValid))
                    .disabled(!viewModel.isFormValid)
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
                Button("Cancel", action: viewModel.cancel)
                    .foregroundStyle(AppColor.accent)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
                    .foregroundStyle(AppColor.accent)
            }
        }
    }

    private var lessonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Lessons *", accessory: "\(viewModel.lessons.count)")

            HStack(spacing: 8) {
                TextField("Lesson title", text: $viewModel.lessonTitle)
                    .padding()
                    .background(AppColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .focused($focusedField, equals: .lessonTitle)

                TextField("Min", text: $viewModel.lessonDuration)
                    .padding()
                    .background(AppColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .focused($focusedField, equals: .lessonDuration)
                    .frame(width: 70)
                    .keyboardType(.numberPad)

                Button(action: viewModel.addLesson) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.lessonFormValid ? AppColor.accent : AppColor.textSecondary)
                }
                .disabled(!viewModel.lessonFormValid)
            }

            ForEach(viewModel.lessons) { lesson in
                HStack(spacing: 10) {
                    Text("\(lesson.order)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 24, height: 24)
                        .background(AppColor.accent.opacity(0.12))
                        .clipShape(Circle())

                    Text(lesson.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    if let duration = lesson.duration {
                        Text("\(duration) min")
                            .font(.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    Button {
                        viewModel.removeLesson(lesson)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColor.danger.opacity(0.7))
                    }
                }
                .padding(12)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .appCard()
    }

    private func fieldBlock<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.textSecondary)
            content()
        }
    }
}
