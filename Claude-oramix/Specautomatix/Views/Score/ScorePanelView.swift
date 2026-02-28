import SwiftUI

struct ScorePanelView: View {
    let spec: Spec

    private static let categoryOrder: [CheckCategory] = [
        .completeness,
        .clarity,
        .testability,
        .safety
    ]

    var body: some View {
        let score = StaticScorer().score(spec)
        let grouped = Dictionary(grouping: score.checks, by: \.category)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                scoreHeaderSection(score: score)

                Divider()

                checklistSection(grouped: grouped)

                if !score.suggestions.isEmpty {
                    Divider()

                    suggestionsSection(suggestions: score.suggestions)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func scoreHeaderSection(score: SpecScore) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Text("\(score.total)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(ScoreBadgeView.color(for: score.grade))

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text("Grade")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(score.grade.rawValue)
                        .font(.title2.bold())
                        .foregroundColor(ScoreBadgeView.color(for: score.grade))
                }

                agentReadyBadge(isReady: score.isAgentReady)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private func agentReadyBadge(isReady: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isReady ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.caption)
            Text(isReady ? "Agent Ready" : "Not Ready")
                .font(.caption.bold())
        }
        .foregroundColor(isReady ? .green : .red)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isReady ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
        )
    }

    @ViewBuilder
    private func checklistSection(grouped: [CheckCategory: [ScoreCheck]]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Checklist")
                .font(.headline)

            ForEach(Self.categoryOrder, id: \.self) { category in
                if let checks = grouped[category], !checks.isEmpty {
                    ChecklistGroupView(category: category, checks: checks)
                }
            }
        }
    }

    @ViewBuilder
    private func suggestionsSection(suggestions: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Suggestions")
                .font(.headline)

            ForEach(suggestions, id: \.self) { suggestion in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                        .padding(.top, 2)

                    Text(suggestion)
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
