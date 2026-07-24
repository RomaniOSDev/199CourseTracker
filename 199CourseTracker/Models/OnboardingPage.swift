import Foundation

struct OnboardingPage: Identifiable, Hashable {
    let id: Int
    let eyebrow: String
    let title: String
    let subtitle: String
    let bulletPoints: [String]
    let imageName: String
    let accentHex: String
}

enum OnboardingContent {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            eyebrow: "Daily practice",
            title: "Build Today's Ritual",
            subtitle: "Start each day with 1–3 sharp learning steps — not an endless course list.",
            bulletPoints: [
                "Auto-picks your next lessons",
                "Mark steps done as you go",
                "Stay focused on what matters today"
            ],
            imageName: "HomeRitualArt",
            accentHex: "02AFEF"
        ),
        OnboardingPage(
            id: 1,
            eyebrow: "Deep work",
            title: "Focus, Then Reflect",
            subtitle: "Run 25 or 45 minute sessions tied to a lesson, then answer a short reflection.",
            bulletPoints: [
                "Timer linked to a real lesson",
                "Pause anytime, finish when ready",
                "Reflection fuels your recall streak"
            ],
            imageName: "HomeFocusArt",
            accentHex: "018CD0"
        ),
        OnboardingPage(
            id: 2,
            eyebrow: "Lasting memory",
            title: "Teach-Back & Skill Path",
            subtitle: "Unlock the next lesson by teaching what you learned — and grow on a visual skill map.",
            bulletPoints: [
                "Summary or 3 flashcards to unlock",
                "Real activity heatmap & streaks",
                "Courses as nodes on skill branches"
            ],
            imageName: "HomeSkillPathArt",
            accentHex: "02AFEF"
        )
    ]
}
