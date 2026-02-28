import XCTest
@testable import Claude_oramix

final class StaticScorerSafetyBonusTests: XCTestCase {

    // MARK: - Helper

    private func makeFullSpec() -> Spec {
        var spec = Spec(title: "Full Spec")
        spec.sections.what = "Add French locale support to the date formatter. The formatter currently supports en-US only."
        spec.sections.where_ = [FileTarget(path: "A.swift", description: "Main file")]
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "g1", when_: "w1", then_: "Returns '15/03/2025'", type: .happyPath),
            AcceptanceCriteria(given: "g2", when_: "w2", then_: "Displays error 'Invalid format'", type: .errorCase)
        ]
        spec.sections.nonGoals = ["Do not modify the calendar component"]
        spec.sections.patterns = [PatternRef(name: "ISO8601", reference: "Use ISO8601 formatting")]
        spec.sections.context = "The app currently only supports en-US locale."
        spec.sections.technicalNotes = "Merge-safe: additive only — new formatter extension."
        spec.metadata.estimate = 1
        return spec
    }

    // MARK: - Cycle 1 — S1

    func test_cycle1_s1PassesWithNonGoal() {
        let spec = makeFullSpec()
        let result = StaticScorer().score(spec)
        let s1 = result.checks.first { $0.name == "non_goals_present" }
        XCTAssertNotNil(s1)
        XCTAssertTrue(s1!.passed)
        XCTAssertEqual(s1!.weight, 10)
    }

    // MARK: - Cycle 2 — S2

    func test_cycle2_s2PassesWithLowEstimate() {
        var spec = makeFullSpec()
        spec.metadata.estimate = 2
        let result = StaticScorer().score(spec)
        let s2 = result.checks.first { $0.name == "scope_reasonable" }
        XCTAssertNotNil(s2)
        XCTAssertTrue(s2!.passed)
        XCTAssertEqual(s2!.weight, 5)
    }

    func test_cycle2_s2FailsWithHighEstimate() {
        var spec = makeFullSpec()
        spec.metadata.estimate = 5
        let result = StaticScorer().score(spec)
        let s2 = result.checks.first { $0.name == "scope_reasonable" }
        XCTAssertNotNil(s2)
        XCTAssertFalse(s2!.passed)
    }

    // MARK: - Cycle 3 — S3

    func test_cycle3_s3PassesWithMergeSafeKeyword() {
        var spec = makeFullSpec()
        spec.sections.technicalNotes = "Merge-safe: additive only, no existing behavior modified."
        let result = StaticScorer().score(spec)
        let s3 = result.checks.first { $0.name == "merge_safe" }
        XCTAssertNotNil(s3)
        XCTAssertTrue(s3!.passed)
        XCTAssertEqual(s3!.weight, 5)
    }

    func test_cycle3_s3FailsWithoutKeyword() {
        var spec = makeFullSpec()
        spec.sections.technicalNotes = "This modifies the core date formatter."
        spec.sections.nonGoals = []
        let result = StaticScorer().score(spec)
        let s3 = result.checks.first { $0.name == "merge_safe" }
        XCTAssertNotNil(s3)
        XCTAssertFalse(s3!.passed)
    }

    // MARK: - Cycle 4 — B1

    func test_cycle4_b1PassesWithPattern() {
        let spec = makeFullSpec()
        let result = StaticScorer().score(spec)
        let b1 = result.checks.first { $0.name == "patterns_referenced" }
        XCTAssertNotNil(b1)
        XCTAssertTrue(b1!.passed)
        XCTAssertEqual(b1!.weight, 5)
    }

    // MARK: - Cycle 5 — B2 + B3

    func test_cycle5_b2PassesWithContext() {
        let spec = makeFullSpec()
        let result = StaticScorer().score(spec)
        let b2 = result.checks.first { $0.name == "context_provided" }
        XCTAssertNotNil(b2)
        XCTAssertTrue(b2!.passed)
        XCTAssertEqual(b2!.weight, 3)
    }

    func test_cycle5_b3PassesWithTechnicalNotes() {
        let spec = makeFullSpec()
        let result = StaticScorer().score(spec)
        let b3 = result.checks.first { $0.name == "technical_notes" }
        XCTAssertNotNil(b3)
        XCTAssertTrue(b3!.passed)
        XCTAssertEqual(b3!.weight, 2)
    }

    // MARK: - Full spec score

    func test_fullSpec_reachesHighScore() {
        let spec = makeFullSpec()
        let result = StaticScorer().score(spec)
        // C1(15)+C2(15)+C3(15)+C4(5) + CL1(10)+CL2(10) + T1(10)+T2(5) + S1(10)+S2(5)+S3(5) + B1(5)+B2(3)+B3(2) = 115, capped to 100
        XCTAssertEqual(result.total, 100)
        XCTAssertEqual(result.grade, .A)
        XCTAssertTrue(result.isAgentReady)
    }
}
