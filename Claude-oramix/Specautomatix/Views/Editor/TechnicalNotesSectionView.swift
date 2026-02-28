import SwiftUI

struct TechnicalNotesSectionView: View {
    @Binding var technicalNotes: String?

    var body: some View {
        GroupBox(label: Text("Technical Notes").font(.headline)) {
            TextEditor(text: Binding(
                get: { technicalNotes ?? "" },
                set: { technicalNotes = $0.isEmpty ? nil : $0 }
            ))
            .frame(minHeight: 60)
            .overlay(alignment: .topLeading) {
                if (technicalNotes ?? "").isEmpty {
                    Text("Notes techniques, contraintes d'implémentation...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}
