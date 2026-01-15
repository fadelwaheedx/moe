import SwiftUI
import SwiftData

struct PromptEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let prompt: Prompt?

    @State private var title = ""
    @State private var content = ""
    @State private var isFavorite = false
    @State private var selectedCategory: Category?

    @Query(sort: \Category.name) private var categories: [Category]

    init(prompt: Prompt?) {
        self.prompt = prompt
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    Toggle("Favorite", isOn: $isFavorite)
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(Optional<Category>.none)
                        ForEach(categories) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    }
                }

                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                        .font(.body)
                }

                Section {
                    Text("Use {{variable}} to insert placeholders.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(prompt == nil ? "New Prompt" : "Edit Prompt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let prompt = prompt {
                    title = prompt.title
                    content = prompt.content
                    isFavorite = prompt.isFavorite
                    selectedCategory = prompt.category
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 400)
        #endif
    }

    private func save() {
        if let prompt = prompt {
            prompt.title = title
            prompt.content = content
            prompt.isFavorite = isFavorite
            prompt.category = selectedCategory
        } else {
            let newPrompt = Prompt(title: title, content: content, isFavorite: isFavorite, category: selectedCategory)
            modelContext.insert(newPrompt)
        }
        dismiss()
    }
}
