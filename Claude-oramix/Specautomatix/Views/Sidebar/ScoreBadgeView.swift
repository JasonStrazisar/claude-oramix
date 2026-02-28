import SwiftUI

struct ScoreBadgeView: View {
    let grade: ScoreGrade

    var body: some View {
        Text(grade.rawValue)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(ScoreBadgeView.color(for: grade))
            .cornerRadius(4)
    }
}

extension ScoreBadgeView {
    static func color(for grade: ScoreGrade) -> Color {
        switch grade {
        case .A: return .green
        case .B: return .blue
        case .C: return .orange
        case .D: return .red
        case .F: return .gray
        }
    }
}
