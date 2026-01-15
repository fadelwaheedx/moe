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

    init(title: String, content: String, isFavorite: Bool = false, category: Category? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.isFavorite = isFavorite
        self.category = category
    }
}
