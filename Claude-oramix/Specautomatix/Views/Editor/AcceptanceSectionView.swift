import SwiftUI

struct AcceptanceSectionView: View {
    @Binding var criteria: [AcceptanceCriteria]

    var body: some View {
        EditorSection(icon: "checkmark.shield", title: "Acceptance Criteria") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach($criteria) { $criterion in
                    AcceptanceCriteriaRowView(
                        criterion: $criterion,
                        onDelete: { removeCriterion(criterion) }
                    )
                }

                Button(action: addCriterion) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Add criterion")
                            .font(.callout)
                    }
                    .foregroundColor(Color.theme.accent)
                }
                .buttonStyle(.plain)
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
