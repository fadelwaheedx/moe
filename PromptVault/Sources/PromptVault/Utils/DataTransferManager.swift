import Foundation
import SwiftData
import SwiftUI

struct DataTransferManager {

    struct ExportData: Codable {
        struct PromptData: Codable {
            let id: UUID
            let title: String
            let content: String
            let isFavorite: Bool
            let createdAt: Date
            let categoryName: String?
            let tags: [String]
        }

        let version: Int
        let prompts: [PromptData]
    }

    static func encodePrompts(_ prompts: [Prompt]) throws -> Data {
        let exportPrompts = prompts.map { prompt in
            ExportData.PromptData(
                id: prompt.id,
                title: prompt.title,
                content: prompt.content,
                isFavorite: prompt.isFavorite,
                createdAt: prompt.createdAt,
                categoryName: prompt.category?.name,
                tags: prompt.tags?.map { $0.name } ?? []
            )
        }

        let exportData = ExportData(version: 1, prompts: exportPrompts)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(exportData)
    }

    static func importPrompts(from url: URL, context: ModelContext) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let exportData = try decoder.decode(ExportData.self, from: data)

        // Fetch existing categories and tags to avoid duplicates
        let categoryDescriptor = FetchDescriptor<Category>()
        let tagDescriptor = FetchDescriptor<Tag>()

        let existingCategories = try context.fetch(categoryDescriptor)
        let existingTags = try context.fetch(tagDescriptor)

        for pData in exportData.prompts {
            // Resolve Category
            var category: Category?
            if let catName = pData.categoryName {
                if let existing = existingCategories.first(where: { $0.name == catName }) {
                    category = existing
                } else {
                    let newCat = Category(name: catName)
                    context.insert(newCat)
                    category = newCat
                }
            }

            // Resolve Tags
            var tags: [Tag] = []
            for tagName in pData.tags {
                if let existing = existingTags.first(where: { $0.name == tagName }) {
                    tags.append(existing)
                } else {
                    let newTag = Tag(name: tagName)
                    context.insert(newTag)
                    tags.append(newTag)
                }
            }

            // Create Prompt
            let prompt = Prompt(
                title: pData.title,
                content: pData.content,
                isFavorite: pData.isFavorite,
                category: category,
                tags: tags
            )
            // Preserve original ID and Date if desired, or let them generate new ones to avoid collisions?
            // User might want to overwrite or duplicate. For simplicity, we create new records but could check ID.
            // Let's create new records to be safe against ID conflicts from other vaults.

            context.insert(prompt)
        }
    }
}
