import SwiftUI

struct SpecRowView: View {
    let spec: Spec

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                Text(spec.title)
                    .font(.system(.body, design: .default).weight(.medium))
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 4)

                ScoreBadgeView(grade: spec.score.grade, size: .small)
            }

            HStack(spacing: 6) {
                StatusBadgeView(status: spec.status)

                if let issueRef = spec.issueRef {
                    Text(issueRef)
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(Color.theme.textTertiary)
                }
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 2)
    }
}
