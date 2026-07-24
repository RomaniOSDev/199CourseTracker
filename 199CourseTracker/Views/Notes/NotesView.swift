import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel: NoteViewModel
    @State private var showAddSheet = false

    init(viewModel: NoteViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 16) {
                ScreenHeader(
                    eyebrow: "Course journal",
                    title: "Notes",
                    subtitle: viewModel.course.title
                )

                Button {
                    viewModel.editingNote = nil
                    showAddSheet = true
                } label: {
                    Label("Add Note", systemImage: "plus.circle.fill")
                }
                .buttonStyle(PrimaryButtonStyle())

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.notes) { note in
                            NoteCell(
                                note: note,
                                onEdit: {
                                    viewModel.editingNote = note
                                    showAddSheet = true
                                },
                                onDelete: { viewModel.deleteNote(note) }
                            )
                        }
                    }
                    .padding(.bottom, 24)
                }
                .clearScrollBackground()
                .overlay {
                    if viewModel.notes.isEmpty {
                        EmptyStateView(
                            icon: "📝",
                            title: "No Notes Yet",
                            message: "Capture insights, examples, and questions for this course",
                            buttonTitle: "Add Note",
                            action: {
                                viewModel.editingNote = nil
                                showAddSheet = true
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
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
        .sheet(isPresented: $showAddSheet) {
            AddNoteSheet(
                title: viewModel.editingNote?.title ?? "",
                content: viewModel.editingNote?.content ?? "",
                isEditing: viewModel.editingNote != nil,
                onSave: { title, content in
                    if var note = viewModel.editingNote {
                        note.title = title
                        note.content = content
                        viewModel.updateNote(note)
                    } else {
                        viewModel.addNote(title: title, content: content)
                    }
                    showAddSheet = false
                    viewModel.editingNote = nil
                },
                onCancel: {
                    showAddSheet = false
                    viewModel.editingNote = nil
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear { viewModel.loadNotes() }
    }
}

private struct AddNoteSheet: View {
    @State var title: String
    @State var content: String
    let isEditing: Bool
    let onSave: (String, String) -> Void
    let onCancel: () -> Void

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(isEditing ? "Edit Note" : "Add Note")
                .font(.headline.weight(.bold))
                .foregroundStyle(AppColor.textPrimary)

            TextField("Title", text: $title)
                .padding()
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            TextEditor(text: $content)
                .frame(minHeight: 140)
                .padding(12)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .scrollContentBackground(.hidden)

            HStack(spacing: 12) {
                Button("Cancel", action: onCancel)
                    .buttonStyle(SecondaryButtonStyle(tint: AppColor.textSecondary))

                Button("Save") {
                    onSave(title, content)
                }
                .buttonStyle(PrimaryButtonStyle(enabled: isFormValid))
                .disabled(!isFormValid)
            }
        }
        .padding(20)
        .background(AppColor.card)
    }
}
