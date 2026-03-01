import SwiftUI
import AppKit

struct PromptPreviewView: View {
    let spec: Spec
    @State private var copied = false

    private var prompt: String {
        PromptBuilder.build(from: spec)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Toolbar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "eye")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.theme.textTertiary)
                    Text("Prompt Preview")
                        .font(.system(.callout, design: .default).weight(.semibold))
                        .foregroundColor(Color.theme.textSecondary)
                }

                Spacer()

                Button(action: copyToClipboard) {
                    HStack(spacing: 5) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11, weight: .semibold))
                        Text(copied ? "Copied!" : "Copy")
                            .font(.callout)
                    }
                    .foregroundColor(copied ? Color.theme.gradeAText : Color.theme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(copied ? Color.theme.gradeABadge : Color.theme.accentLight)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.2), value: copied)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.theme.surface)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.theme.border),
                alignment: .bottom
            )

            // Content
            ScrollView {
                Text(prompt)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
            .background(Color.theme.background)
        }
        .background(Color.theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
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
