import SwiftUI

struct ContextSectionView: View {
    @Binding var context: String?

    var body: some View {
        GroupBox(label: Text("Context").font(.headline)) {
            TextEditor(text: Binding(
                get: { context ?? "" },
                set: { context = $0.isEmpty ? nil : $0 }
            ))
            .frame(minHeight: 60)
            .overlay(alignment: .topLeading) {
                if (context ?? "").isEmpty {
                    Text("Ajoutez du contexte...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}
