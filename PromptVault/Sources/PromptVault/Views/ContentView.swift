import SwiftUI
import SwiftData

enum SidebarSelection: Hashable {
    case all
    case favorites
    case category(Category)
}

struct ContentView: View {
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var selection: SidebarSelection? = .all
    @State private var selectedPrompt: Prompt?

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selection: $selection)
        } content: {
            PromptListView(selection: selection, selectedPrompt: $selectedPrompt)
        } detail: {
            PromptDetailView(prompt: selectedPrompt)
        }
        .navigationTitle("PromptVault")
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
    }
}
