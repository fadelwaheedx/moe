import SwiftUI
import SwiftData

@main
struct PromptVaultApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Prompt.self,
            Category.self,
            Tag.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)

        MenuBarExtra("PromptVault", systemImage: "text.append") {
            MenuBarList()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)

        Window("About PromptVault", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
    }
}
