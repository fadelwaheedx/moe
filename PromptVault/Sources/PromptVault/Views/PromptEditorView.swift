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
    @State private var selectedTags: [Tag] = []
    @State private var newTagName = ""

    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \Tag.name) private var allTags: [Tag]

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

                Section("Tags") {
                    HStack {
                        TextField("Add new tag", text: $newTagName)
                            .onSubmit {
                                addNewTag()
                            }
                        Button(action: addNewTag) {
                            Image(systemName: "plus")
                        }
                        .disabled(newTagName.isEmpty)
                    }

                    if !selectedTags.isEmpty {
                        FlowLayout(alignment: .leading, spacing: 5) {
                            ForEach(selectedTags) { tag in
                                HStack(spacing: 4) {
                                    Text(tag.name)
                                    Button(action: { toggleTag(tag) }) {
                                        Image(systemName: "xmark")
                                            .font(.caption2)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                    }

                    if !allTags.isEmpty {
                        Menu("Add Existing Tag") {
                            ForEach(allTags) { tag in
                                Button(action: { toggleTag(tag) }) {
                                    HStack {
                                        Text(tag.name)
                                        if selectedTags.contains(tag) {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
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
                    selectedTags = prompt.tags ?? []
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 600)
        #endif
    }

    private func addNewTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Check if tag exists
        let tag: Tag
        if let existing = allTags.first(where: { $0.name.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }) {
            tag = existing
        } else {
            tag = Tag(name: trimmed)
            modelContext.insert(tag)
        }

        if !selectedTags.contains(tag) {
            selectedTags.append(tag)
        }
        newTagName = ""
    }

    private func toggleTag(_ tag: Tag) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }

    private func save() {
        if let prompt = prompt {
            prompt.title = title
            prompt.content = content
            prompt.isFavorite = isFavorite
            prompt.category = selectedCategory
            prompt.tags = selectedTags
        } else {
            let newPrompt = Prompt(title: title, content: content, isFavorite: isFavorite, category: selectedCategory, tags: selectedTags)
            modelContext.insert(newPrompt)
        }
        dismiss()
    }
}

// Simple FlowLayout helper for tags
struct FlowLayout: Layout {
    var alignment: Alignment = .center
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        let width = proposal.width ?? rows.map { $0.width }.max() ?? 0
        let height = rows.last?.maxY ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        for row in rows {
            for element in row.elements {
                element.subview.place(at: CGPoint(x: bounds.minX + element.x, y: bounds.minY + element.y), proposal: .unspecified)
            }
        }
    }

    struct Row {
        var elements: [Element] = []
        var y: CGFloat = 0
        var height: CGFloat = 0
        var width: CGFloat = 0
        var maxY: CGFloat { y + height }
    }

    struct Element {
        var subview: LayoutSubview
        var x: CGFloat
        var y: CGFloat
    }

    func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var x: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > maxWidth && !currentRow.elements.isEmpty {
                currentRow.width = x
                rows.append(currentRow)
                currentRow = Row(y: rows.last?.maxY ?? 0 + spacing)
                x = 0
            }

            currentRow.elements.append(Element(subview: subview, x: x, y: currentRow.y))
            currentRow.height = max(currentRow.height, size.height)
            x += size.width + spacing
        }

        if !currentRow.elements.isEmpty {
            currentRow.width = x
            rows.append(currentRow)
        }

        return rows
    }
}
