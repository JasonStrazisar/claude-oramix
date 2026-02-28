import SwiftUI

struct ChecklistGroupView: View {
    let category: CheckCategory
    let checks: [ScoreCheck]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Category header
            Text(categoryLabel.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color.theme.textTertiary)
                .tracking(0.8)
                .padding(.bottom, 2)

            // Check rows
            ForEach(checks) { check in
                checkRow(check: check)
            }
        }
    }

    @ViewBuilder
    private func checkRow(check: ScoreCheck) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 8) {
                checkIcon(for: check)
                    .frame(width: 16, height: 16)

                Text(check.name
                    .replacingOccurrences(of: "_", with: " ")
                    .capitalized
                )
                .font(.callout)
                .foregroundColor(Color.theme.textPrimary)

                Spacer()

                Text("\(check.weight)pt")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.theme.textTertiary)
            }

            // Failure hint
            if !check.passed && !check.message.contains("N/A") && !check.message.isEmpty {
                Text(check.message)
                    .font(.caption)
                    .foregroundColor(Color.theme.textTertiary)
                    .padding(.leading, 24)
            }
        }
    }

    @ViewBuilder
    private func checkIcon(for check: ScoreCheck) -> some View {
        if check.message.contains("N/A") {
            Image(systemName: "minus")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color.theme.textTertiary)
        } else if check.passed {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color.theme.gradeAAccent)
        } else {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color.theme.gradeDAccent)
        }
    }

    private var categoryLabel: String {
        switch category {
        case .completeness: return "Completeness"
        case .clarity:      return "Clarity"
        case .testability:  return "Testability"
        case .scope:        return "Scope"
        case .safety:       return "Safety"
        }
    }
}
