import SwiftUI

struct SkillPathView: View {
    @StateObject private var viewModel: SkillPathViewModel

    init(viewModel: SkillPathViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Map",
                        title: "Skill Path",
                        subtitle: "Courses live as nodes on skill branches."
                    )

                    HStack(spacing: 10) {
                        Button {
                            viewModel.rebuildFromCourses()
                        } label: {
                            Label("Rebuild", systemImage: "arrow.triangle.2.circlepath")
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button {
                            viewModel.showAddSheet = true
                        } label: {
                            Label("Add Node", systemImage: "plus")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }

                    if viewModel.branches.isEmpty {
                        EmptyStateView(
                            icon: "🌳",
                            title: "Empty Path",
                            message: "Add courses, then rebuild — or create custom skill nodes",
                            buttonTitle: "Rebuild",
                            action: viewModel.rebuildFromCourses
                        )
                        .appCard()
                    } else {
                        ForEach(viewModel.branches) { branch in
                            SkillBranchCell(
                                branch: branch,
                                onOpenCourse: viewModel.openCourse,
                                onDelete: viewModel.deleteNode
                            )
                        }
                    }
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
        .sheet(isPresented: $viewModel.showAddSheet) {
            addNodeSheet
                .presentationDetents([.medium])
        }
        .onAppear { viewModel.loadData() }
    }

    private var addNodeSheet: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Add Skill Node")
                .font(.headline.weight(.bold))

            TextField("Node title (e.g. Swift Concurrency)", text: $viewModel.newNodeTitle)
                .padding()
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Picker("Parent branch", selection: $viewModel.selectedParentId) {
                Text("New Root Branch").tag(UUID?.none)
                ForEach(viewModel.branches) { branch in
                    Text(branch.root.title).tag(Optional(branch.root.id))
                }
            }
            .pickerStyle(.menu)

            Picker("Link course (optional)", selection: $viewModel.selectedCourseId) {
                Text("No course link").tag(UUID?.none)
                ForEach(viewModel.courses) { course in
                    Text(course.title).tag(Optional(course.id))
                }
            }
            .pickerStyle(.menu)

            Button(action: viewModel.addNode) {
                Text("Save Node")
            }
            .buttonStyle(PrimaryButtonStyle())

            Spacer()
        }
        .padding(20)
    }
}

private struct SkillBranchCell: View {
    let branch: SkillPathBranch
    let onOpenCourse: (UUID) -> Void
    let onDelete: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SkillNodeCell(
                title: branch.root.title,
                subtitle: branch.root.detail ?? "Branch",
                isRoot: true,
                onTap: nil,
                onDelete: { onDelete(branch.root.id) }
            )

            ForEach(Array(branch.children.enumerated()), id: \.element.id) { index, child in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(AppColor.accent.opacity(0.35))
                            .frame(width: 2, height: 16)
                        Circle()
                            .fill(AppColor.accent)
                            .frame(width: 9, height: 9)
                        if index < branch.children.count - 1 {
                            Rectangle()
                                .fill(AppColor.accent.opacity(0.35))
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 12)

                    SkillNodeCell(
                        title: child.title,
                        subtitle: child.detail,
                        isRoot: false,
                        onTap: child.linkedCourseId.map { id in { onOpenCourse(id) } },
                        onDelete: { onDelete(child.id) }
                    )
                }
                .padding(.leading, 10)
                .padding(.top, 8)
            }
        }
        .appCard(level: .raised)
    }
}

private struct SkillNodeCell: View {
    let title: String
    let subtitle: String?
    let isRoot: Bool
    let onTap: (() -> Void)?
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(
                systemName: isRoot ? "point.topleft.down.to.point.bottomright.curvepath.fill" : "circle.fill",
                color: isRoot ? AppColor.accentSecondary : AppColor.accent,
                size: isRoot ? 42 : 34
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(isRoot ? .headline.weight(.bold) : .subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }

            Spacer()

            if onTap != nil {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundStyle(AppColor.accent)
            }

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(AppColor.danger.opacity(0.85))
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isRoot ? AppDepth.Surfaces.accentSoft : AppDepth.Surfaces.inset)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isRoot ? AppColor.accent.opacity(0.2) : AppDepth.Strokes.subtle, lineWidth: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }
}
