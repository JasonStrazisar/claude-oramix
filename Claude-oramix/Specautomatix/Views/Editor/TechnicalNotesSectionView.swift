import SwiftUI

struct TechnicalNotesSectionView: View {
    @Binding var technicalNotes: String?

    var body: some View {
        EditorSection(icon: "wrench.and.screwdriver", title: "Technical Notes") {
            ZStack(alignment: .topLeading) {
                if (technicalNotes ?? "").isEmpty {
                    Text("Implementation constraints, performance targets, architecture notes…")
                        .font(.callout)
                        .foregroundColor(Color.theme.textTertiary)
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }

                TextEditor(text: Binding(
                    get: { technicalNotes ?? "" },
                    set: { technicalNotes = $0.isEmpty ? nil : $0 }
                ))
                .font(.callout)
                .frame(minHeight: 70)
                .scrollContentBackground(.hidden)
                .background(Color.theme.surfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color.theme.borderLight, lineWidth: 1)
                )
            }
        }
    }
}
