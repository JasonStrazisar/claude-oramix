import Foundation

// MARK: - StaticScorer

struct StaticScorer {

    func score(_ spec: Spec) -> SpecScore {
        var checks: [ScoreCheck] = []
        checks += checkCompleteness(spec)
        // Future: checks += checkClarity(spec)
        // Future: checks += checkTestability(spec)
        // Future: checks += checkScope(spec)
        // Future: checks += checkSafety(spec)
        let total = min(100, checks.filter { $0.passed }.map { $0.weight }.reduce(0, +))
        let grade = computeGrade(total)
        return SpecScore(
            total: total,
            grade: grade,
            checks: checks,
            suggestions: [],
            isAgentReady: grade == .A || grade == .B
        )
    }

    // MARK: - Completeness checks

    private func checkCompleteness(_ spec: Spec) -> [ScoreCheck] {
        [
            checkC1(spec),
            checkC2(spec),
            checkC3(spec),
            checkC4(spec)
        ]
    }

    private func checkC1(_ spec: Spec) -> ScoreCheck {
        let passed = !spec.sections.what.isEmpty && spec.sections.what.count > 50
        return makeCheck(
            category: .completeness,
            name: "what_present",
            passed: passed,
            weight: 15,
            message: passed
                ? "Section 'what' is present and sufficiently detailed."
                : "Section 'what' must be non-empty and longer than 50 characters."
        )
    }

    private func checkC2(_ spec: Spec) -> ScoreCheck {
        let passed = !spec.sections.where_.isEmpty
        return makeCheck(
            category: .completeness,
            name: "files_listed",
            passed: passed,
            weight: 15,
            message: passed
                ? "At least one target file is identified."
                : "At least one target file must be listed."
        )
    }

    private func checkC3(_ spec: Spec) -> ScoreCheck {
        let passed = spec.sections.acceptance.count >= 2
        return makeCheck(
            category: .completeness,
            name: "acceptance_present",
            passed: passed,
            weight: 15,
            message: passed
                ? "At least two acceptance criteria are defined."
                : "At least two acceptance criteria are required."
        )
    }

    private func checkC4(_ spec: Spec) -> ScoreCheck {
        let hasFiles = !spec.sections.where_.isEmpty
        let allHaveDescription = spec.sections.where_.allSatisfy { !$0.description.isEmpty }
        let passed = hasFiles && allHaveDescription
        let weight = hasFiles ? 5 : 0
        return makeCheck(
            category: .completeness,
            name: "files_have_description",
            passed: passed,
            weight: weight,
            message: passed
                ? "All target files have a description."
                : hasFiles
                    ? "Every target file must have a non-empty description."
                    : "No target files to check for descriptions."
        )
    }

    // MARK: - Helpers

    private func makeCheck(
        category: CheckCategory,
        name: String,
        passed: Bool,
        weight: Int,
        message: String
    ) -> ScoreCheck {
        ScoreCheck(
            id: UUID(),
            category: category,
            name: name,
            passed: passed,
            weight: weight,
            message: message
        )
    }

    private func computeGrade(_ total: Int) -> ScoreGrade {
        switch total {
        case 90...100: return .A
        case 80..<90:  return .B
        case 60..<80:  return .C
        case 40..<60:  return .D
        default:       return .F
        }
    }
}
