import SwiftUI

struct ChecklistGroupView: View {
    let category: CheckCategory
    let checks: [ScoreCheck]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(category.rawValue.capitalized)
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            ForEach(checks) { check in
                HStack(spacing: 8) {
                    checkIcon(for: check)
                        .frame(width: 16, height: 16)

                    Text(check.name.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.caption)

                    Spacer()

                    Text("(\(check.weight))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private func checkIcon(for check: ScoreCheck) -> some View {
        if check.message.contains("N/A") {
            Image(systemName: "minus")
                .foregroundColor(.gray)
                .font(.caption)
        } else if check.passed {
            Image(systemName: "checkmark")
                .foregroundColor(.green)
                .font(.caption)
        } else {
            Image(systemName: "xmark")
                .foregroundColor(.red)
                .font(.caption)
        }
    }
}
