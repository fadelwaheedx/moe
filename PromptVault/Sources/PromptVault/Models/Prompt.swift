import Foundation
import SwiftData

@Model
final class Prompt {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var isFavorite: Bool

    @Relationship(inverse: \Category.prompts)
    var category: Category?

    @Relationship(deleteRule: .nullify)
    var tags: [Tag]? = []

    init(title: String, content: String, isFavorite: Bool = false, category: Category? = nil, tags: [Tag] = []) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.isFavorite = isFavorite
        self.category = category
        self.tags = tags
    }
}
