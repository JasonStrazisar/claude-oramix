import SwiftUI

struct AcceptanceSectionView: View {
    @Binding var criteria: [AcceptanceCriteria]

    var body: some View {
        GroupBox(label: Text("Acceptance Criteria").font(.headline)) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach($criteria) { $criterion in
                    AcceptanceCriteriaRowView(
                        criterion: $criterion,
                        onDelete: { removeCriterion(criterion) }
                    )
                }

                Button(action: addCriterion) {
                    Label("Add criterion", systemImage: "plus")
                }
            }
        }
    }

    private func addCriterion() {
        criteria.append(AcceptanceCriteria())
    }

    private func removeCriterion(_ criterion: AcceptanceCriteria) {
        criteria.removeAll { $0.id == criterion.id }
    }
}
