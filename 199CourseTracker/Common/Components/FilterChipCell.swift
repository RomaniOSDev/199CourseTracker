import SwiftUI

struct FilterChipCell: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                }
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .foregroundStyle(isSelected ? Color.white : AppColor.textPrimary)
            .background {
                Capsule()
                    .fill(
                        isSelected
                            ? AppDepth.Surfaces.accent
                            : AppDepth.Surfaces.card
                    )
            }
            .overlay {
                Capsule()
                    .stroke(
                        isSelected ? Color.white.opacity(0.35) : AppDepth.Strokes.subtle,
                        lineWidth: 1
                    )
            }
            .depthShadow(isSelected ? .raised : .card)
        }
        .buttonStyle(.plain)
    }
}
