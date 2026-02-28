import SwiftUI

struct SettingsPlaceholderView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)

                    Text("Settings")
                        .font(.largeTitle)
                        .bold()

                    Text("Configuration à venir : Ollama endpoint, export format, Shortcut API key.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Text("Coming Soon")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(8)
                }
                .padding(.top, 32)

                Form {
                    Section("Ollama Configuration") {
                        TextField("Endpoint URL", text: .constant("http://localhost:11434"))
                            .disabled(true)
                        TextField("Model", text: .constant("qwen2.5-coder:3b"))
                            .disabled(true)
                    }

                    Section("Export Preferences") {
                        TextField("Default format", text: .constant("Markdown"))
                            .disabled(true)
                    }

                    Section("Shortcut Integration") {
                        SecureField("API Key", text: .constant(""))
                            .disabled(true)
                    }
                }
                .formStyle(.grouped)
                .disabled(true)
                .opacity(0.5)
            }
            .padding()
        }
    }
}
