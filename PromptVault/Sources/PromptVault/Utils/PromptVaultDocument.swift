import SwiftUI
import UniformTypeIdentifiers

struct PromptVaultDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var prompts: [Prompt]

    init(prompts: [Prompt]) {
        self.prompts = prompts
    }

    init(configuration: ReadConfiguration) throws {
        // We don't need read support for the Document logic here since we use DataTransferManager for import
        self.prompts = []
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try DataTransferManager.encodePrompts(prompts)
        return FileWrapper(regularFileWithContents: data)
    }
}
