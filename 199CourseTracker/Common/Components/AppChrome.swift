import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            AppColor.background

            // Lightweight static wash — no blur (keeps scroll smooth)
            AppDepth.Surfaces.screen
                .opacity(0.95)

            // Soft accent orbs via opacity gradients only
            Ellipse()
                .fill(AppDepth.Surfaces.panelGlow)
                .frame(width: 320, height: 220)
                .offset(x: 120, y: -260)

            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColor.accentSecondary.opacity(0.10),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 280, height: 200)
                .offset(x: -130, y: 340)
        }
        .ignoresSafeArea()
    }
}

struct ScreenHeader<Trailing: View>: View {
    let eyebrow: String?
    let title: String
    let subtitle: String?
    let trailing: Trailing

    init(
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(AppColor.accent)
                }
                Text(title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 12)
            trailing
        }
    }
}

struct SectionHeaderView: View {
    let title: String
    var accessory: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            if let accessory {
                Text(accessory)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppDepth.Surfaces.inset)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppDepth.Strokes.subtle, lineWidth: 1))
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColor.accent)
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var enabled: Bool = true
    var color: Color = AppColor.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        enabled
                            ? LinearGradient(
                                colors: [color, color.opacity(0.78)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [
                                    AppColor.textSecondary.opacity(0.35),
                                    AppColor.textSecondary.opacity(0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
            }
            .overlay(alignment: .top) {
                if enabled {
                    Capsule()
                        .fill(Color.white.opacity(0.28))
                        .frame(height: 6)
                        .padding(.horizontal, 22)
                        .padding(.top, 5)
                        .allowsHitTesting(false)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .depthShadow(enabled ? .raised : .flat)
            .scaleEffect(configuration.isPressed && enabled ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var tint: Color = AppColor.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.16), tint.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(tint.opacity(0.18), lineWidth: 1)
            }
            .depthShadow(.flat)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct IconBadge: View {
    let systemName: String
    var color: Color = AppColor.accent
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.24), color.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
            Image(systemName: systemName)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
        .depthShadow(.flat)
    }
}
