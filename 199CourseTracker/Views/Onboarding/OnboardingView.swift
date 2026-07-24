import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                TabView(selection: $viewModel.currentPage) {
                    ForEach(viewModel.pages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: viewModel.currentPage)

                bottomControls
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
            }
        }
        .screenContainer()
    }

    private var topBar: some View {
        HStack {
            ProgressBarView(progress: viewModel.progress, height: 6)
                .frame(maxWidth: 140)

            Spacer()

            if !viewModel.isLastPage {
                Button("Skip") {
                    viewModel.complete(onFinished: onFinished)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.textSecondary)
            }
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 14) {
            pageIndicators

            if viewModel.isLastPage {
                Button {
                    viewModel.complete(onFinished: onFinished)
                } label: {
                    Label("Get Started", systemImage: "arrow.right.circle.fill")
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.next()
                    }
                } label: {
                    Label("Continue", systemImage: "arrow.right")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    private var pageIndicators: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.pages) { page in
                Capsule()
                    .fill(
                        page.id == viewModel.currentPage
                            ? AppDepth.Surfaces.accent
                            : LinearGradient(
                                colors: [AppColor.surface, AppColor.surface],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .frame(
                        width: page.id == viewModel.currentPage ? 22 : 8,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.2), value: viewModel.currentPage)
            }
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack(alignment: .bottomLeading) {
                    Image(page.imageName)
                        .resizable()
                        .interpolation(.medium)
                        .scaledToFill()
                        .frame(height: 240)
                        .frame(maxWidth: .infinity)
                        .clipped()

                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.35)
                        ],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppDepth.Strokes.card, lineWidth: 1)
                }
                .depthShadow(.hero)
                .padding(.horizontal, 20)
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 12) {
                    Text(page.eyebrow.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(0.9)
                        .foregroundStyle(Color(hex: page.accentHex))

                    Text(page.title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)

                    Text(page.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(page.bulletPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color(hex: page.accentHex))
                                Text(point)
                                    .font(.subheadline)
                                    .foregroundStyle(AppColor.textPrimary)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCard(padding: 18, radius: 22, level: .raised)
                .padding(.horizontal, 20)

                Spacer(minLength: 12)
            }
        }
        .clearScrollBackground()
    }
}

#Preview {
    OnboardingView(onFinished: {})
}
