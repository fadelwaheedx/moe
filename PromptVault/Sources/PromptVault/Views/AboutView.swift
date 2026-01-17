import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.append")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)

            VStack(spacing: 5) {
                Text("PromptVault")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Version 1.1")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("A native macOS vault for your prompts.\nOrganize, variable-inject, and deploy.")
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.horizontal)

            Text("© 2024 EcoSys")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(width: 350)
    }
}
