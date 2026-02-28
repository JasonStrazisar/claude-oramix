import SwiftUI

struct SpecRowView: View {
    let spec: Spec

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 6) {
                Text(spec.title)
                    .font(.body)
                    .lineLimit(1)
                Spacer()
                ScoreBadgeView(grade: spec.score.grade)
            }
            HStack(spacing: 6) {
                Text(spec.status.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                    )
                if let shortcutId = spec.shortcutId {
                    Text(shortcutId)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
