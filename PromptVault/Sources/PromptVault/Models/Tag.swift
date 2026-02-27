import Foundation
import SwiftData

@Model
final class Tag {
    var id: UUID
    var name: String

    @Relationship(inverse: \Prompt.tags)
    var prompts: [Prompt]? = []

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
