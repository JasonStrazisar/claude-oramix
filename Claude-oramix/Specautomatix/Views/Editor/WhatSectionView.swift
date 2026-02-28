import SwiftUI

struct WhatSectionView: View {
    @Binding var what: String

    var body: some View {
        EditorSection(icon: "doc.text", title: "What") {
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $what)
                    .font(.system(.body))
                    .frame(minHeight: 90)
                    .scrollContentBackground(.hidden)
                    .background(Color.theme.surfaceRaised)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color.theme.borderLight, lineWidth: 1)
                    )

                HStack {
                    Spacer()
                    Text("\(what.count)/50")
                        .font(.caption)
                        .foregroundColor(what.count < 50 ? Color.theme.destructive : Color.theme.textTertiary)
                }
            }
        }
    }
}
