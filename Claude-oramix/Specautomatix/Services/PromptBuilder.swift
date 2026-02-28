import Foundation

struct PromptBuilder {
    static func build(from spec: Spec) -> String {
        var parts: [String] = []

        parts.append(taskSection(spec))
        parts.append(descriptionSection(spec))

        if !spec.sections.where_.isEmpty {
            parts.append(filesSection(spec))
        }

        if !spec.sections.acceptance.isEmpty {
            parts.append(acceptanceSection(spec))
        }

        if !spec.sections.nonGoals.isEmpty {
            parts.append(nonGoalsSection(spec))
        }

        if !spec.sections.patterns.isEmpty {
            parts.append(patternsSection(spec))
        }

        if let context = spec.sections.context, !context.isEmpty {
            parts.append("## Context\n\(context)")
        }

        if let notes = spec.sections.technicalNotes, !notes.isEmpty {
            parts.append("## Technical Notes\n\(notes)")
        }

        parts.append(instructionsSection(spec))

        return parts.joined(separator: "\n\n")
    }
}

// MARK: - Private Section Formatters

private extension PromptBuilder {
    static func taskSection(_ spec: Spec) -> String {
        "## Task\n\(spec.title)"
    }

    static func descriptionSection(_ spec: Spec) -> String {
        "## Description\n\(spec.sections.what)"
    }

    static func filesSection(_ spec: Spec) -> String {
        let files = spec.sections.where_
            .map { "- `\($0.path)`: \($0.description)" }
            .joined(separator: "\n")
        return "## Files to modify\n\(files)"
    }

    static func acceptanceSection(_ spec: Spec) -> String {
        let criteria = spec.sections.acceptance.map { c in
            "- **[\(c.type.rawValue)]** Given: \(c.given) | When: \(c.when_) | Then: \(c.then_)"
        }.joined(separator: "\n")
        return "## Acceptance Criteria\n\(criteria)"
    }

    static func nonGoalsSection(_ spec: Spec) -> String {
        let nonGoals = spec.sections.nonGoals
            .map { "- \($0)" }
            .joined(separator: "\n")
        return "## Non-Goals (DO NOT)\n\(nonGoals)"
    }

    static func patternsSection(_ spec: Spec) -> String {
        let patterns = spec.sections.patterns
            .map { "- \($0.name): \($0.reference)" }
            .joined(separator: "\n")
        return "## Patterns to follow\n\(patterns)"
    }

    static func instructionsSection(_ spec: Spec) -> String {
        let branchId = spec.shortcutId ?? String(spec.id.uuidString.prefix(8))
        let slug = spec.title.slugified
        return "## Instructions\n- Branch: `sc-\(branchId)/\(slug)`\n- Implement changes, write tests for each criterion, ensure all pass\n- Commit with descriptive message referencing the spec"
    }
}

// MARK: - String Extension

private extension String {
    var slugified: String {
        self.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
    }
}
