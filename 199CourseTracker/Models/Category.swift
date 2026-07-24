import Foundation

enum Category: String, CaseIterable, Codable, Hashable {
    case programming = "Programming"
    case design = "Design"
    case business = "Business"
    case language = "Languages"
    case science = "Science"
    case math = "Mathematics"
    case art = "Art"
    case music = "Music"
    case fitness = "Fitness"
    case other = "Other"

    var icon: String {
        switch self {
        case .programming: return "💻"
        case .design: return "🎨"
        case .business: return "💼"
        case .language: return "🌍"
        case .science: return "🔬"
        case .math: return "📐"
        case .art: return "🎭"
        case .music: return "🎵"
        case .fitness: return "🏃"
        case .other: return "📚"
        }
    }

    var color: String {
        switch self {
        case .programming: return "02AFEF"
        case .design: return "FF6B6B"
        case .business: return "018CD0"
        case .language: return "00B894"
        case .science: return "6C5CE7"
        case .math: return "FFD93D"
        case .art: return "E17055"
        case .music: return "A29BFE"
        case .fitness: return "4CAF50"
        case .other: return "6B7B8D"
        }
    }
}
