import Foundation

struct SkillPathNode: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var detail: String?
    var parentId: UUID?
    var linkedCourseId: UUID?
    var sortOrder: Int
}

struct SkillPathBranch: Identifiable, Hashable {
    let id: UUID
    let root: SkillPathNode
    let children: [SkillPathNode]
}
