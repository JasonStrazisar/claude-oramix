import SwiftUI

/// Pill badge displaying a SpecStatus with its semantic color.
struct StatusBadgeView: View {
    let status: SpecStatus

    var body: some View {
        Text(statusLabel)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(Color.theme.statusColor(for: status))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color.theme.statusBgColor(for: status))
            .clipShape(Capsule())
    }

    private var statusLabel: String {
        switch status {
        case .draft:      return "Draft"
        case .ready:      return "Ready"
        case .queued:     return "Queued"
        case .inProgress: return "In Progress"
        case .done:       return "Done"
        case .failed:     return "Failed"
        case .split:      return "Split"
        }
    }
}
