import SwiftUI

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch cleaned.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Loading syndicate aliases → existing asset colors
    static let appBackground = Color("BackgroundPrimary")
    static let appSurface = Color("CardBackground")
    static let appPrimary = Color("AccentPrimary")
    static let appAccent = Color("AccentSecondary")
    static let appTextPrimary = Color("TextPrimary")
    static let appTextSecondary = Color("TextSecondary")
}

enum AppColor {
    /// #333B64 — main screen background
    static let background = Color("BackgroundPrimary")
    /// #2FAA52 — main buttons, key UI
    static let accent = Color("AccentPrimary")
    /// #59BB75 — highlights, progress, active states
    static let accentSecondary = Color("AccentSecondary")
    /// #FFFFFF
    static let textPrimary = Color("TextPrimary")
    /// #9CA3AF
    static let textSecondary = Color("TextSecondary")
    /// #4B5377 — cards, panels, modals
    static let card = Color("CardBackground")
    /// Slightly lifted panel fill for insets / fields
    static let surface = Color(hex: "565E82")
    static let success = Color(hex: "59BB75")
    static let danger = Color(hex: "FF6B6B")
}
