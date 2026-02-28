import Foundation

// MARK: - StaticScorer

struct StaticScorer {

    func score(_ spec: Spec) -> SpecScore {
        var checks: [ScoreCheck] = []
        let completenessResults = checkCompleteness(spec)
        checks += completenessResults
        checks += clarityChecks(spec, completenessResults: completenessResults)
        // Future: checks += testabilityChecks(spec, completenessResults: completenessResults)
        // Future: checks += safetyChecks(spec)
        // Future: checks += bonusChecks(spec)
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

    // MARK: - Clarity checks

    private static let vagueWords: [String] = [
        "should probably",
        "maybe",
        "might",
        "etc.",
        "and so on",
        "improve",
        "better",
        "faster",
        "optimize",
        "fix",
        "handle properly",
        "work correctly",
        "as needed",
        "if necessary",
        "when appropriate",
        "similar to",
        "like before"
    ]

    private func clarityChecks(_ spec: Spec, completenessResults: [ScoreCheck]) -> [ScoreCheck] {
        let c1Passed = completenessResults.first { $0.name == "what_present" }?.passed ?? false
        let c3Passed = completenessResults.first { $0.name == "acceptance_present" }?.passed ?? false
        return [
            checkCL1(spec, c1Passed: c1Passed),
            checkCL2(spec, c3Passed: c3Passed)
        ]
    }

    private func checkCL1(_ spec: Spec, c1Passed: Bool) -> ScoreCheck {
        guard c1Passed else {
            return makeCheck(
                category: .clarity,
                name: "what_no_ambiguity",
                passed: false,
                weight: 0,
                message: "N/A — CL1 requires C1 to pass first."
            )
        }
        let what = spec.sections.what.lowercased()
        let foundVague = StaticScorer.vagueWords.first { vague in
            if vague == "fix" {
                return what.range(
                    of: #"\bfix\b"#,
                    options: [.regularExpression, .caseInsensitive]
                ) != nil
            }
            return what.contains(vague)
        }
        let passed = foundVague == nil
        return makeCheck(
            category: .clarity,
            name: "what_no_ambiguity",
            passed: passed,
            weight: 10,
            message: passed
                ? "Section 'what' contains no ambiguous language."
                : "Section 'what' contains vague term: '\(foundVague ?? "")'."
        )
    }

    private func checkCL2(_ spec: Spec, c3Passed: Bool) -> ScoreCheck {
        guard c3Passed else {
            return makeCheck(
                category: .clarity,
                name: "acceptance_gwt_format",
                passed: false,
                weight: 0,
                message: "N/A — CL2 requires C3 to pass first."
            )
        }
        let allComplete = spec.sections.acceptance.allSatisfy {
            !$0.given.isEmpty && !$0.when_.isEmpty && !$0.then_.isEmpty
        }
        return makeCheck(
            category: .clarity,
            name: "acceptance_gwt_format",
            passed: allComplete,
            weight: 10,
            message: allComplete
                ? "All acceptance criteria have non-empty given, when, and then fields."
                : "Every acceptance criterion must have non-empty given, when, and then fields."
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
