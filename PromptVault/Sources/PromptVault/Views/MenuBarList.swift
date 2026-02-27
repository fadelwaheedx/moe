import SwiftUI
import SwiftData

struct MenuBarList: View {
    @Query(sort: [SortDescriptor(\Prompt.isFavorite, order: .reverse)]) private var prompts: [Prompt]
    @State private var searchText = ""

    var filteredPrompts: [Prompt] {
        if searchText.isEmpty {
            return prompts
        } else {
            return prompts.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search prompts...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(8)

            List(filteredPrompts) { prompt in
                Button {
                    copyToClipboard(prompt)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prompt.title)
                                .font(.headline)
                            Text(prompt.content)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        if prompt.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .frame(maxHeight: 400)

            Divider()

            HStack {
                Button("Open PromptVault") {
                    NSApp.activate(ignoringOtherApps: true)
                    // This relies on the main window being available or finding a way to unhide it
                    if let window = NSApp.windows.first {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
                .buttonStyle(.link)
                .padding(8)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .padding(8)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 300)
    }

    private func copyToClipboard(_ prompt: Prompt) {
        // If variables exist, we can't easily pop UI in menu bar for input without closing menu.
        // For simple menu bar usage, we just copy raw text or text with defaults.
        // For this iteration, we copy raw text.
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(prompt.content, forType: .string)
    }
}
