import SwiftUI

struct PromptDetailView: View {
    let prompt: Prompt?

    @State private var variableValues: [String: String] = [:]
    @State private var generatedContent: String = ""
    @State private var isEditing = false
    @State private var showCopyConfirmation = false

    var body: some View {
        Group {
            if let prompt = prompt {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Text(prompt.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        if prompt.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }

                        Spacer()

                        Button(action: { isEditing = true }) {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                    .padding(.bottom, 10)

                    Divider()

                    // Variable Inputs
                    let variables = VariableInjector.extractVariables(from: prompt.content)
                    if !variables.isEmpty {
                        GroupBox(label: Label("Variables", systemImage: "slider.horizontal.3")) {
                            VStack(alignment: .leading) {
                                ForEach(variables, id: \.self) { variable in
                                    HStack {
                                        Text(variable.capitalized + ":")
                                            .frame(width: 100, alignment: .leading)
                                        TextField("Value for \(variable)", text: Binding(
                                            get: { variableValues[variable] ?? "" },
                                            set: { variableValues[variable] = $0 }
                                        ))
                                        .textFieldStyle(.roundedBorder)
                                    }
                                }
                            }
                            .padding(8)
                        }
                    }

                    // Content Preview
                    GroupBox(label: Label("Preview", systemImage: "doc.text")) {
                        ScrollView {
                            // Using localized string interpolation for Markdown support
                            Text(LocalizedStringKey(filledContent))
                                .font(.body)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                    }

                    // Tags Display
                    if let tags = prompt.tags, !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags) { tag in
                                    Text(tag.name)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Actions
                    HStack {
                        Spacer()
                        Button(action: copyToClipboard) {
                            Label(showCopyConfirmation ? "Copied!" : "Copy to Clipboard", systemImage: "doc.on.doc")
                                .frame(minWidth: 150)
                        }
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .disabled(prompt.content.isEmpty)
                    }
                }
                .padding()
            } else {
                ContentUnavailableView("Select a Prompt", systemImage: "doc.text.magnifyingglass")
            }
        }
        .onChange(of: prompt) { _, _ in
            variableValues = [:]
            showCopyConfirmation = false
        }
        .sheet(isPresented: $isEditing) {
            PromptEditorView(prompt: prompt)
        }
    }

    private var filledContent: String {
        guard let prompt = prompt else { return "" }
        if variableValues.isEmpty {
            return prompt.content
        }
        return VariableInjector.inject(variables: variableValues, into: prompt.content)
    }

    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(filledContent, forType: .string)

        showCopyConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopyConfirmation = false
        }
    }
}
