import SwiftUI

enum ScoreBadgeSize {
    case small   // sidebar: ~26×26
    case large   // score panel: ~56×56
}

struct ScoreBadgeView: View {
    let grade: ScoreGrade
    var size: ScoreBadgeSize = .small

    var body: some View {
        Text(grade.rawValue)
            .font(labelFont)
            .foregroundColor(Color.theme.textColor(for: grade))
            .frame(width: dimension, height: dimension)
            .background(Color.theme.badgeColor(for: grade))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.theme.accentColor(for: grade).opacity(0.35), lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.3), value: grade)
    }

    private var dimension: CGFloat {
        switch size {
        case .small: return 26
        case .large: return 56
        }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .small: return 6
        case .large: return 12
        }
    }

    private var labelFont: Font {
        switch size {
        case .small:
            return .system(size: 12, weight: .heavy, design: .rounded)
        case .large:
            return .system(size: 26, weight: .heavy, design: .rounded)
        }
    }
}

// MARK: - Legacy static helper (kept for backward compat with ScorePanelView)

extension ScoreBadgeView {
    static func color(for grade: ScoreGrade) -> Color {
        Color.theme.textColor(for: grade)
    }
}
