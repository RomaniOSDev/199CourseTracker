import SwiftUI

struct CategoryBadgeView: View {
    let category: Category

    var body: some View {
        Text("\(category.icon) \(category.rawValue)")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color(hex: category.color).opacity(0.12))
            .foregroundStyle(Color(hex: category.color))
            .clipShape(Capsule())
    }
}
