import SwiftUI

struct NonGoalsSectionView: View {
    @Binding var nonGoals: [String]

    var body: some View {
        EditorSection(icon: "xmark.octagon", title: "Non-Goals (Do NOT)") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(nonGoals.indices, id: \.self) { index in
                    HStack(spacing: 8) {
                        Text("–")
                            .font(.callout)
                            .foregroundColor(Color.theme.textTertiary)
                            .frame(width: 12, alignment: .center)

                        TextField("Do NOT…", text: $nonGoals[index])
                            .font(.callout)
                            .textFieldStyle(.plain)
                            .foregroundColor(Color.theme.textPrimary)

                        Button(action: { nonGoals.remove(at: index) }) {
                            Image(systemName: "minus.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(Color.theme.textTertiary)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button(action: { nonGoals.append("") }) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Add non-goal")
                            .font(.callout)
                    }
                    .foregroundColor(Color.theme.accent)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
