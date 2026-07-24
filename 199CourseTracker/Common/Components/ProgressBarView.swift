import SwiftUI

struct ProgressBarView: View {
    let progress: Double
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColor.surface)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [AppColor.accentSecondary, AppColor.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geometry.size.width * min(max(progress, 0), 1)))
            }
        }
        .frame(height: height)
    }
}
