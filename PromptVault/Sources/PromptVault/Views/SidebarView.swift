import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var selection: SidebarSelection?
    @Query(sort: \Category.name) private var categories: [Category]
    @Query private var prompts: [Prompt]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    @State private var showingAddCategory = false
    @State private var newCategoryName = ""

    @State private var isExporting = false
    @State private var isImporting = false
    @State private var importError: Error?
    @State private var showingImportError = false

    var body: some View {
        List(selection: $selection) {
            Section("Library") {
                NavigationLink(value: SidebarSelection.all) {
                    Label("All Prompts", systemImage: "tray.full")
                }
                NavigationLink(value: SidebarSelection.favorites) {
                    Label("Favorites", systemImage: "star.fill")
                }
            }

            Section("Categories") {
                ForEach(categories) { category in
                    NavigationLink(value: SidebarSelection.category(category)) {
                        Label(category.name, systemImage: category.systemImage)
                    }
                    .dropDestination(for: String.self) { items, location in
                        return handleDrop(items: items, to: category)
                    }
                }
                .onDelete(perform: deleteCategories)
            }
        }
        .listStyle(.sidebar)
        .alert("New Category", isPresented: $showingAddCategory) {
            TextField("Name", text: $newCategoryName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                addCategory()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Menu {
                Button {
                    isImporting = true
                } label: {
                    Label("Import JSON...", systemImage: "arrow.down.doc")
                }

                Button {
                    isExporting = true
                } label: {
                    Label("Export JSON...", systemImage: "arrow.up.doc")
                }
            } label: {
                Label("Manage Vault", systemImage: "gear")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
            }
            .menuStyle(.borderlessButton)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddCategory = true }) {
                    Label("Add Category", systemImage: "folder.badge.plus")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button("About") {
                    openWindow(id: "about")
                }
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: PromptVaultDocument(prompts: prompts),
            contentType: .json,
            defaultFilename: "PromptVault_Export"
        ) { result in
            if case .failure(let error) = result {
                print("Export failed: \(error.localizedDescription)")
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                do {
                    try DataTransferManager.importPrompts(from: url, context: modelContext)
                } catch {
                    importError = error
                    showingImportError = true
                }
            case .failure(let error):
                print("Import failed: \(error.localizedDescription)")
            }
        }
        .alert("Import Error", isPresented: $showingImportError) {
            Button("OK") { }
        } message: {
            Text(importError?.localizedDescription ?? "Unknown error")
        }
    }

    private func handleDrop(items: [String], to category: Category) -> Bool {
        guard let uuidString = items.first,
              let uuid = UUID(uuidString: uuidString),
              let prompt = prompts.first(where: { $0.id == uuid }) else {
            return false
        }

        prompt.category = category
        return true
    }

    private func addCategory() {
        guard !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let category = Category(name: newCategoryName)
        modelContext.insert(category)
        newCategoryName = ""
    }

    private func deleteCategories(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(categories[index])
        }
    }
}
