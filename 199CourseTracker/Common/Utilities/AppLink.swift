import Foundation

enum AppLink: String {
    case privacyPolicy = "https://www.termsfeed.com/live/c23f90d2-b000-4105-8c9d-793f4e01547b"
    case termsOfUse = "https://www.termsfeed.com/live/6d8c0c6d-37fb-4a77-bf93-940005aeb1d6"

    var url: URL? {
        URL(string: rawValue)
    }
}
