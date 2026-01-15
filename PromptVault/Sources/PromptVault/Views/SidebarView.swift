import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var selection: SidebarSelection?
    @Query(sort: \Category.name) private var categories: [Category]
    @Environment(\.modelContext) private var modelContext

    @State private var showingAddCategory = false
    @State private var newCategoryName = ""

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
                }
                .onDelete(perform: deleteCategories)
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddCategory = true }) {
                    Label("Add Category", systemImage: "folder.badge.plus")
                }
            }
        }
        .alert("New Category", isPresented: $showingAddCategory) {
            TextField("Name", text: $newCategoryName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                addCategory()
            }
        }
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
