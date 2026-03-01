import SwiftUI

struct ScorePanelView: View {
    let spec: Spec
    var scorer: OllamaScorer = OllamaScorer()

    @State private var state = ScorePanelState()
    @State private var showSplitSheet = false
    @State private var splitProposals: [SplitProposal] = []

    var shouldShowSplitButton: Bool {
        (spec.metadata.estimate ?? 0) > 3 || state.ollamaAnalysis?.splitSuggestions.isEmpty == false
    }

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
                scoreHeader(score: score)

                Divider()
                    .background(Color.theme.border)

                checklistSection(grouped: grouped)

                if !score.suggestions.isEmpty {
                    Divider()
                        .background(Color.theme.border)

                    suggestionsSection(suggestions: score.suggestions)
                }

                Divider()
                    .background(Color.theme.border)

                ollamaSection

                if shouldShowSplitButton {
                    Divider()
                        .background(Color.theme.border)

                    splitSection
                }
            }
            .padding(20)
        }
        .background(Color.theme.surface)
    }

    // MARK: - Score header

    @ViewBuilder
    private func scoreHeader(score: SpecScore) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Big score + grade badge
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(score.total)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color.theme.textColor(for: score.grade))
                        .animation(.easeInOut(duration: 0.3), value: score.total)

                    Text("out of 100")
                        .font(.caption)
                        .foregroundColor(Color.theme.textTertiary)
                }

                Spacer()

                ScoreBadgeView(grade: score.grade, size: .large)
            }

            // Agent ready badge
            agentReadyBadge(isReady: score.isAgentReady)
        }
        .padding(16)
        .background(Color.theme.badgeColor(for: score.grade).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private func agentReadyBadge(isReady: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: isReady ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 13, weight: .semibold))
            Text(isReady ? "Agent Ready" : "Not Ready")
                .font(.system(.callout, design: .default).weight(.semibold))
        }
        .foregroundColor(isReady ? Color.theme.gradeAText : Color.theme.gradeDText)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(isReady ? Color.theme.gradeABadge : Color.theme.gradeDBadge)
        .clipShape(Capsule())
    }

    // MARK: - Checklist

    @ViewBuilder
    private func checklistSection(grouped: [CheckCategory: [ScoreCheck]]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Checklist")
                .font(.system(.headline, design: .default).weight(.semibold))
                .foregroundColor(Color.theme.textPrimary)

            ForEach(Self.categoryOrder, id: \.self) { category in
                if let checks = grouped[category], !checks.isEmpty {
                    ChecklistGroupView(category: category, checks: checks)
                }
            }
        }
    }

    // MARK: - Suggestions

    @ViewBuilder
    private func suggestionsSection(suggestions: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Suggestions")
                .font(.system(.headline, design: .default).weight(.semibold))
                .foregroundColor(Color.theme.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(Color.theme.gradeCAccent)
                            .font(.system(size: 11))
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

    // MARK: - Ollama section

    @ViewBuilder
    private var ollamaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                Task { await runOllamaCheck() }
            } label: {
                HStack(spacing: 8) {
                    if state.isChecking {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text("Check with Ollama")
                        .font(.system(.callout, design: .default).weight(.medium))
                }
            }
            .disabled(state.isCheckButtonDisabled)
            .keyboardShortcut("S", modifiers: [.command, .shift])

            OllamaAnalysisView(
                analysis: state.ollamaAnalysis,
                isLoading: state.isChecking
            )
        }
    }

    // MARK: - Split section

    @ViewBuilder
    private var splitSection: some View {
        Button {
            splitProposals = SplitEngine().propose(spec: spec, ollamaAnalysis: state.ollamaAnalysis)
            showSplitSheet = true
        } label: {
            Label("Split this spec", systemImage: "scissors")
                .font(.system(.callout, design: .default).weight(.medium))
        }
        .sheet(isPresented: $showSplitSheet) {
            SplitProposalView(
                proposals: $splitProposals,
                onConfirm: { _ in showSplitSheet = false },
                onCancel: { showSplitSheet = false }
            )
        }
    }

    // MARK: - Private

    @MainActor
    private func runOllamaCheck() async {
        state.isChecking = true
        defer { state.isChecking = false }
        state.ollamaAnalysis = try? await scorer.analyzeQuality(spec: spec)
    }
}
