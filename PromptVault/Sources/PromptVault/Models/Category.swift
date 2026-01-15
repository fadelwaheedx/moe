import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var systemImage: String

    @Relationship(deleteRule: .cascade)
    var prompts: [Prompt]? = []

    init(name: String, systemImage: String = "folder") {
        self.id = UUID()
        self.name = name
        self.systemImage = systemImage
    }
}
