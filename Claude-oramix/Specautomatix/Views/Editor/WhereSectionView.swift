import SwiftUI

struct WhereSectionView: View {
    @Binding var fileTargets: [FileTarget]

    var body: some View {
        EditorSection(icon: "folder", title: "Where (Files)") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach($fileTargets) { $target in
                    fileRow(target: $target)
                }

                addButton(label: "Add file", icon: "plus") {
                    fileTargets.append(FileTarget())
                }
            }
        }
    }

    @ViewBuilder
    private func fileRow(target: Binding<FileTarget>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("path/to/File.swift", text: target.path)
                        .font(.system(.callout, design: .monospaced))
                        .foregroundColor(Color.theme.accent)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.theme.accentLight)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

                    TextField("Description", text: target.description)
                        .font(.callout)
                        .foregroundColor(Color.theme.textSecondary)
                        .textFieldStyle(.plain)
                }

                Button(action: { removeTarget(target.wrappedValue) }) {
                    Image(systemName: "minus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(Color.theme.textTertiary)
                }
                .buttonStyle(.plain)
            }

            Divider().opacity(0.5)
        }
    }

    private func removeTarget(_ target: FileTarget) {
        fileTargets.removeAll { $0.id == target.id }
    }
}

// MARK: - Shared add button helper (file-scoped)

private func addButton(label: String, icon: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(label)
                .font(.callout)
        }
        .foregroundColor(Color.theme.accent)
    }
    .buttonStyle(.plain)
}
