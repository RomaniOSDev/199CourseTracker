import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 52))
                .padding(18)
                .background(AppColor.accent.opacity(0.1))
                .clipShape(Circle())

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColor.textPrimary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            if !buttonTitle.isEmpty {
                Button(action: action) {
                    Text(buttonTitle)
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: 220)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }
}
