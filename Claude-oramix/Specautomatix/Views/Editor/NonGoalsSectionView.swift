import SwiftUI

struct NonGoalsSectionView: View {
    @Binding var nonGoals: [String]

    var body: some View {
        GroupBox(label: Text("Non-Goals (Do NOT)").font(.headline)) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(nonGoals.indices, id: \.self) { index in
                    HStack {
                        TextField("Do NOT...", text: $nonGoals[index])
                        Button(action: { nonGoals.remove(at: index) }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Button(action: { nonGoals.append("") }) {
                    Label("Add non-goal", systemImage: "plus")
                }
            }
        }
    }
}
