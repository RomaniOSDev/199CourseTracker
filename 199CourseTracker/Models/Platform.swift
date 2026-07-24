import Foundation

enum Platform: String, CaseIterable, Codable, Hashable {
    case coursera = "Coursera"
    case udemy = "Udemy"
    case edx = "edX"
    case skillshare = "Skillshare"
    case youtube = "YouTube"
    case stepik = "Stepik"
    case other = "Other"

    var color: String {
        switch self {
        case .coursera: return "02AFEF"
        case .udemy: return "FF6B6B"
        case .edx: return "6C5CE7"
        case .skillshare: return "00B894"
        case .youtube: return "FF0000"
        case .stepik: return "4CAF50"
        case .other: return "6B7B8D"
        }
    }
}
