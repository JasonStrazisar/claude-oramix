import SwiftUI

struct OllamaAnalysisView: View {
    let analysis: OllamaAnalysis?
    var isLoading: Bool = false

    var body: some View {
        EditorSection(icon: "brain", title: "Ollama Analysis") {
            if isLoading {
                loadingContent
            } else if let analysis {
                analysisContent(analysis: analysis)
            } else {
                placeholderContent
            }
        }
    }

    // MARK: - States

    private var loadingContent: some View {
        HStack(spacing: 10) {
            ProgressView()
                .controlSize(.small)
            Text("Analyzing with Ollama…")
                .font(.callout)
                .foregroundColor(Color.theme.textTertiary)
        }
    }

    private var placeholderContent: some View {
        Text("No Ollama analysis — click 'Check with Ollama' to analyze")
            .font(.callout)
            .foregroundColor(Color.theme.textTertiary)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Analysis content

    @ViewBuilder
    private func analysisContent(analysis: OllamaAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            scoreHeader(qualityScore: analysis.qualityScore)

            if !analysis.suggestions.isEmpty {
                suggestionsSection(suggestions: analysis.suggestions)
            }

            if !analysis.splitSuggestions.isEmpty {
                splitSuggestionsSection(splitSuggestions: analysis.splitSuggestions)
            }
        }
    }

    // MARK: - Score header

    private func scoreHeader(qualityScore: Double) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(scoreLabel(for: qualityScore))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(scoreColor(for: qualityScore))

            VStack(alignment: .leading, spacing: 2) {
                Text("Semantic Quality")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.theme.textTertiary)
                    .tracking(0.8)
                    .textCase(.uppercase)

                Text(scoreDescription(for: qualityScore))
                    .font(.caption)
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
    }

    // MARK: - Suggestions

    private func suggestionsSection(suggestions: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggestions".uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color.theme.textTertiary)
                .tracking(0.8)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color.theme.gradeCAccent)
                            .padding(.top, 2)

                        Text(suggestion)
                            .font(.callout)
                            .foregroundColor(Color.theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(12)
            .background(Color.theme.gradeCBadge.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    // MARK: - Split suggestions

    private func splitSuggestionsSection(splitSuggestions: [SplitSuggestion]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Split Suggestions".uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color.theme.textTertiary)
                .tracking(0.8)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(splitSuggestions, id: \.title) { split in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "scissors")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.theme.accent)
                            .padding(.top, 1)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(split.title)
                                .font(.callout.weight(.semibold))
                                .foregroundColor(Color.theme.textPrimary)

                            Text(split.rationale)
                                .font(.caption)
                                .foregroundColor(Color.theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
        }
    }

    // MARK: - Helpers

    private func scoreLabel(for qualityScore: Double) -> String {
        "\(Int((qualityScore * 100).rounded()))%"
    }

    private func scoreColor(for qualityScore: Double) -> Color {
        if qualityScore >= 0.7 {
            return Color.theme.gradeAAccent
        } else if qualityScore >= 0.4 {
            return Color.theme.gradeCAccent
        } else {
            return Color.theme.gradeDAccent
        }
    }

    private func scoreDescription(for qualityScore: Double) -> String {
        if qualityScore >= 0.7 {
            return "Good semantic quality"
        } else if qualityScore >= 0.4 {
            return "Needs improvement"
        } else {
            return "Low quality — review required"
        }
    }
}
