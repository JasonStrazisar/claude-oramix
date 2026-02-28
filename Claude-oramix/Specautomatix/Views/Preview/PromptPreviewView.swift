import SwiftUI
import AppKit

struct PromptPreviewView: View {
    let spec: Spec
    @State private var copied = false

    private var prompt: String {
        PromptBuilder.build(from: spec)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Prompt Preview")
                    .font(.headline)
                Spacer()
                Button(action: copyToClipboard) {
                    Label(copied ? "Copied!" : "Copy to Clipboard",
                          systemImage: copied ? "checkmark" : "doc.on.doc")
                }
            }

            ScrollView {
                Text(prompt)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(6)
        }
        .padding()
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(prompt, forType: .string)
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}
