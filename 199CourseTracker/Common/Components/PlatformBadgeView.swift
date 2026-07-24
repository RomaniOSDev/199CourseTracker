import SwiftUI

struct PlatformBadgeView: View {
    let platform: Platform

    var body: some View {
        Text(platform.rawValue)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color(hex: platform.color).opacity(0.14))
            .foregroundStyle(Color(hex: platform.color))
            .clipShape(Capsule())
    }
}
