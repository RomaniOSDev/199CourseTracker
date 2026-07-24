import SwiftUI

/// Optimized depth tokens: static gradients + one shadow per surface.
/// Avoids blur, nested shadows, and animated fills for scroll performance.
enum AppDepth {
    enum Level {
        case flat
        case card
        case raised
        case hero
    }

    enum Surfaces {
        static let card = LinearGradient(
            colors: [
                Color(hex: "555D82"),
                Color(hex: "4B5377")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let inset = LinearGradient(
            colors: [
                Color(hex: "5A6288"),
                Color(hex: "4B5377")
            ],
            startPoint: .top,
            endPoint: .bottom
        )

        static let accent = LinearGradient(
            colors: [
                AppColor.accent,
                AppColor.accentSecondary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let accentSoft = LinearGradient(
            colors: [
                AppColor.accent.opacity(0.28),
                AppColor.accentSecondary.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let screen = LinearGradient(
            colors: [
                Color(hex: "3A4270"),
                Color(hex: "333B64"),
                Color(hex: "2E355C")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let panelGlow = LinearGradient(
            colors: [
                AppColor.accent.opacity(0.16),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    enum Strokes {
        static let card = LinearGradient(
            colors: [
                Color.white.opacity(0.14),
                AppColor.accent.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let subtle = AppColor.accent.opacity(0.16)
    }

    static func shadowColor(for level: Level) -> Color {
        switch level {
        case .flat: return .clear
        case .card: return Color.black.opacity(0.28)
        case .raised: return Color.black.opacity(0.35)
        case .hero: return AppColor.accent.opacity(0.28)
        }
    }

    static func shadowRadius(for level: Level) -> CGFloat {
        switch level {
        case .flat: return 0
        case .card: return 10
        case .raised: return 12
        case .hero: return 14
        }
    }

    static func shadowY(for level: Level) -> CGFloat {
        switch level {
        case .flat: return 0
        case .card: return 5
        case .raised: return 6
        case .hero: return 8
        }
    }
}

struct DepthShadowModifier: ViewModifier {
    let level: AppDepth.Level

    func body(content: Content) -> some View {
        content.shadow(
            color: AppDepth.shadowColor(for: level),
            radius: AppDepth.shadowRadius(for: level),
            x: 0,
            y: AppDepth.shadowY(for: level)
        )
    }
}

struct AppCardModifier: ViewModifier {
    var padding: CGFloat = 16
    var radius: CGFloat = 18
    var level: AppDepth.Level = .card
    var showStroke: Bool = true

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(AppDepth.Surfaces.card)
            }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                if showStroke {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(AppDepth.Strokes.card, lineWidth: 1)
                }
            }
            .modifier(DepthShadowModifier(level: level))
    }
}

struct InsetPanelModifier: ViewModifier {
    var padding: CGFloat = 12
    var radius: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(AppDepth.Surfaces.inset)
            }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(AppColor.accent.opacity(0.12), lineWidth: 1)
            }
    }
}

extension View {
    func appCard(
        padding: CGFloat = 16,
        radius: CGFloat = 18,
        level: AppDepth.Level = .card,
        showStroke: Bool = true
    ) -> some View {
        modifier(AppCardModifier(padding: padding, radius: radius, level: level, showStroke: showStroke))
    }

    func insetPanel(padding: CGFloat = 12, radius: CGFloat = 14) -> some View {
        modifier(InsetPanelModifier(padding: padding, radius: radius))
    }

    func depthShadow(_ level: AppDepth.Level) -> some View {
        modifier(DepthShadowModifier(level: level))
    }

    func screenContainer() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
    }

    func volumeHighlight(radius: CGFloat = 18) -> some View {
        overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 18)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
