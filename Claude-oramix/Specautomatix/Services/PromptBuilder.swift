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

// MARK: - Conversational Context

extension PromptBuilder {
    static func buildConversationalContext(tempFilePath: String, projectPath: String) -> String {
        """
        You are a senior software engineer analyzing a Swift/SwiftUI macOS project.

        Project path: \(projectPath)

        Your task is to analyze the project at the path above and produce a structured specification in JSON format. Write the JSON to the file at this path: \(tempFilePath)

        The JSON must conform to the following structure (all keys required):
        {
          "what": "A concise description of the feature or change",
          "where": [
            { "path": "Relative/Path/To/File.swift", "description": "What this file does" }
          ],
          "acceptance": [
            { "type": "happy_path", "given": "...", "when_": "...", "then_": "..." }
          ],
          "nonGoals": ["List of things explicitly out of scope"],
          "patterns": [
            { "name": "PatternName", "reference": "Where this pattern is used in the codebase" }
          ]
        }

        Read the CLAUDE.md file at \(projectPath)/CLAUDE.md for additional project conventions. Write only the JSON to \(tempFilePath), with no additional commentary.
        """
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
        let branchId = spec.issueRef ?? String(spec.id.uuidString.prefix(8))
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
