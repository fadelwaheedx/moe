import SwiftUI
import SwiftData

struct PromptListView: View {
    var selection: SidebarSelection?
    @Binding var selectedPrompt: Prompt?

    @Query(sort: [SortDescriptor(\Prompt.isFavorite, order: .reverse), SortDescriptor(\Prompt.createdAt, order: .reverse)]) private var prompts: [Prompt]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showingAddPrompt = false

    var filteredPrompts: [Prompt] {
        let filtered: [Prompt]
        switch selection {
        case .all, .none:
            filtered = prompts
        case .favorites:
            filtered = prompts.filter { $0.isFavorite }
        case .category(let category):
            filtered = prompts.filter { $0.category == category }
        }

        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        List(filteredPrompts, selection: $selectedPrompt) { prompt in
            VStack(alignment: .leading) {
                HStack {
                    Text(prompt.title)
                        .font(.headline)
                    if prompt.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                Text(prompt.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .tag(prompt)
            .contextMenu {
                Button(role: .destructive) {
                    deletePrompt(prompt)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddPrompt = true }) {
                    Label("Add Prompt", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPrompt) {
            PromptEditorView(prompt: nil)
        }
    }

    private func deletePrompt(_ prompt: Prompt) {
        modelContext.delete(prompt)
        if selectedPrompt == prompt {
            selectedPrompt = nil
        }
    }
}
