import Foundation

// MARK: - SplitProposal

struct SplitProposal {
    let title: String
    let what: String
    let estimate: Int
}

// MARK: - SplitEngine

struct SplitEngine {

    private let minEstimateForSplit = 3

    func propose(spec: Spec, ollamaAnalysis: OllamaAnalysis?) -> [SplitProposal] {
        let ollamaProposals = ollamaAnalysis.flatMap { analysis -> [SplitProposal]? in
            guard !analysis.splitSuggestions.isEmpty else { return nil }
            return analysis.splitSuggestions.map { suggestion in
                SplitProposal(
                    title: suggestion.title,
                    what: suggestion.rationale,
                    estimate: max(1, (spec.metadata.estimate ?? 2) / 2)
                )
            }
        }

        if let proposals = ollamaProposals {
            return proposals
        }

        if (spec.metadata.estimate ?? 0) > minEstimateForSplit {
            return defaultSplitProposals(for: spec)
        }

        return []
    }

    // MARK: - Private

    private func defaultSplitProposals(for spec: Spec) -> [SplitProposal] {
        let halfEstimate = max(1, (spec.metadata.estimate ?? 4) / 2)
        return [
            SplitProposal(
                title: "\(spec.title) — Part 1/2",
                what: "First half of: \(spec.title)",
                estimate: halfEstimate
            ),
            SplitProposal(
                title: "\(spec.title) — Part 2/2",
                what: "Second half of: \(spec.title)",
                estimate: halfEstimate
            )
        ]
    }
}
