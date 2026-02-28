import SwiftUI

struct PatternsSectionView: View {
    @Binding var patterns: [PatternRef]

    var body: some View {
        GroupBox(label: Text("Patterns to Follow").font(.headline)) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach($patterns) { $pattern in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Pattern name", text: $pattern.name)
                                .bold()
                            TextField("Reference", text: $pattern.reference)
                                .foregroundColor(.secondary)
                        }
                        Button(action: { removePattern(pattern) }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    Divider()
                }
                Button(action: { patterns.append(PatternRef()) }) {
                    Label("Add pattern", systemImage: "plus")
                }
            }
        }
    }

    private func removePattern(_ pattern: PatternRef) {
        patterns.removeAll { $0.id == pattern.id }
    }
}
