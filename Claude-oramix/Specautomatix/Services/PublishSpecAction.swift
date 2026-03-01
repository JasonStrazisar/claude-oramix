import Foundation

// MARK: - PublishSpecAction

struct PublishSpecAction {

    /// Publie une spec vers un IssueTracker, met à jour issueRef et persiste via SpecStore.
    /// - Parameters:
    ///   - spec: La spec à publier (score.total doit être ≥ 80, vérifié en amont par la vue).
    ///   - project: Le projet actif (issueTracker doit être configuré).
    ///   - provider: Le provider IssueTracker à appeler.
    ///   - store: Le SpecStore pour persister la mise à jour de issueRef.
    /// - Returns: L'URL de l'issue créée.
    @discardableResult
    func execute(
        spec: Spec,
        project: Project,
        provider: any IssueTrackerProvider,
        store: SpecStore
    ) async throws -> String {
        let body = buildIssueBody(for: spec)
        let created = try await provider.createIssue(title: spec.title, body: body)
        try await provider.addComment(issueNumber: created.number, body: buildCommentBody(for: spec))

        var updated = spec
        updated.issueRef = created.url
        store.update(updated)

        return created.url
    }

    // MARK: - Private

    private func buildIssueBody(for spec: Spec) -> String {
        var lines: [String] = []

        if !spec.sections.what.isEmpty {
            lines.append("## What\n\(spec.sections.what)")
        }

        if !spec.sections.acceptance.isEmpty {
            lines.append("## Acceptance Criteria")
            for ac in spec.sections.acceptance {
                lines.append("- **Given** \(ac.given) **When** \(ac.when_) **Then** \(ac.then_)")
            }
        }

        if !spec.sections.nonGoals.isEmpty {
            lines.append("## Non-Goals")
            for ng in spec.sections.nonGoals {
                lines.append("- \(ng)")
            }
        }

        lines.append("\n---\n*Published by Claude-oramix — Score: \(spec.score.total)/100*")

        return lines.joined(separator: "\n\n")
    }

    private func buildCommentBody(for spec: Spec) -> String {
        "Spec score: **\(spec.score.total)/100** (grade: \(spec.score.grade.rawValue))"
    }
}
