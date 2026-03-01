import SwiftUI

struct ContextSectionView: View {
    @Binding var context: String?

    var body: some View {
        EditorSection(icon: "info.circle", title: "Context") {
            ZStack(alignment: .topLeading) {
                if (context ?? "").isEmpty {
                    Text("Add context, background info, or relevant links…")
                        .font(.callout)
                        .foregroundColor(Color.theme.textTertiary)
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }

                TextEditor(text: Binding(
                    get: { context ?? "" },
                    set: { context = $0.isEmpty ? nil : $0 }
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
