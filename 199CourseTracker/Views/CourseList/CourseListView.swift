import SwiftUI

struct CourseListView: View {
    @StateObject private var viewModel: CourseListViewModel

    init(viewModel: CourseListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 14) {
                searchBar
                filterRows

                HStack {
                    Text("\(viewModel.filteredCourses.count) courses")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.textSecondary)
                    Spacer()
                    if viewModel.selectedCategory != nil
                        || viewModel.selectedPlatform != nil
                        || viewModel.showCompletedOnly
                        || !viewModel.searchText.isEmpty {
                        Button("Clear filters") {
                            viewModel.searchText = ""
                            viewModel.selectedCategory = nil
                            viewModel.selectedPlatform = nil
                            viewModel.showCompletedOnly = false
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColor.accent)
                    }
                }
                .padding(.horizontal, 20)

                courseList
            }
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.goToCourseForm) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppColor.accent)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Courses")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
        .onAppear { viewModel.loadCourses() }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.accent)
            TextField("Search title or description", text: $viewModel.searchText)
                .foregroundStyle(AppColor.textPrimary)
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppDepth.Surfaces.card)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppDepth.Strokes.card, lineWidth: 1)
        }
        .depthShadow(.card)
        .padding(.horizontal, 20)
    }

    private var filterRows: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChipCell(
                        title: "All",
                        icon: "square.grid.2x2",
                        isSelected: viewModel.selectedCategory == nil
                            && viewModel.selectedPlatform == nil
                            && !viewModel.showCompletedOnly
                    ) {
                        viewModel.selectedCategory = nil
                        viewModel.selectedPlatform = nil
                        viewModel.showCompletedOnly = false
                    }

                    FilterChipCell(
                        title: "Completed",
                        icon: "checkmark.seal",
                        isSelected: viewModel.showCompletedOnly
                    ) {
                        viewModel.showCompletedOnly.toggle()
                    }

                    ForEach(Category.allCases, id: \.self) { category in
                        FilterChipCell(
                            title: "\(category.icon) \(category.rawValue)",
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                            if viewModel.selectedCategory != nil {
                                viewModel.showCompletedOnly = false
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Platform.allCases, id: \.self) { platform in
                        FilterChipCell(
                            title: platform.rawValue,
                            icon: "laptopcomputer",
                            isSelected: viewModel.selectedPlatform == platform
                        ) {
                            viewModel.selectedPlatform =
                                viewModel.selectedPlatform == platform ? nil : platform
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var courseList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(viewModel.filteredCourses) { course in
                    CourseCardView(
                        course: course,
                        onFavorite: { viewModel.toggleFavorite(course) },
                        onTap: { viewModel.goToCourseDetail(course) }
                    )
                    .contextMenu {
                        Button {
                            viewModel.toggleFavorite(course)
                        } label: {
                            Label(
                                course.isFavorite ? "Remove Favorite" : "Favorite",
                                systemImage: course.isFavorite ? "heart.slash" : "heart"
                            )
                        }
                        Button("Delete", role: .destructive) {
                            viewModel.deleteCourse(course)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .padding(.bottom, 24)
        }
        .clearScrollBackground()
        .overlay {
            if viewModel.filteredCourses.isEmpty {
                EmptyStateView(
                    icon: "📚",
                    title: "No Courses",
                    message: viewModel.searchText.isEmpty ? "Add your first course" : "Nothing matches these filters",
                    buttonTitle: "Add Course",
                    action: viewModel.goToCourseForm
                )
            }
        }
    }
}
