import SwiftUI

struct WhatSectionView: View {
    @Binding var what: String

    var body: some View {
        GroupBox(label: Text("What (Description)").font(.headline)) {
            VStack(alignment: .leading, spacing: 4) {
                TextEditor(text: $what)
                    .frame(minHeight: 80)

                HStack {
                    Spacer()
                    Text("\(what.count)/50")
                        .font(.caption)
                        .foregroundColor(what.count < 50 ? .red : .secondary)
                }
            }
        }
    }
}
