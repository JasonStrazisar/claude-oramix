import SwiftUI

struct PatternsSectionView: View {
    @Binding var patterns: [PatternRef]

    var body: some View {
        EditorSection(icon: "book.closed", title: "Patterns to Follow") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach($patterns) { $pattern in
                    patternRow(pattern: $pattern)
                }

                Button(action: { patterns.append(PatternRef()) }) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Add pattern")
                            .font(.callout)
                    }
                    .foregroundColor(Color.theme.accent)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func patternRow(pattern: Binding<PatternRef>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Pattern name", text: pattern.name)
                        .font(.system(.callout, design: .default).weight(.semibold))
                        .foregroundColor(Color.theme.textPrimary)
                        .textFieldStyle(.plain)

                    TextField("Reference (file, doc, URL…)", text: pattern.reference)
                        .font(.callout)
                        .foregroundColor(Color.theme.textSecondary)
                        .textFieldStyle(.plain)
                }

                Button(action: { removePattern(pattern.wrappedValue) }) {
                    Image(systemName: "minus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(Color.theme.textTertiary)
                }
                .buttonStyle(.plain)
            }

            Divider().opacity(0.5)
        }
    }

    private func removePattern(_ pattern: PatternRef) {
        patterns.removeAll { $0.id == pattern.id }
    }
}
