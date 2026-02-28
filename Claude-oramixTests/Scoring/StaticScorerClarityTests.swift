import XCTest
@testable import Claude_oramix

final class StaticScorerClarityTests: XCTestCase {

    private let scorer = StaticScorer()

    // MARK: - Cycle 1: CL1 passes with a precise 'what' (>50 chars, no vague words)

    func test_cycle1_cl1_passesWithPreciseWhat() {
        var spec = Spec(title: "CL1 precise")
        spec.sections.what = "This implementation adds a static scoring function that evaluates specification clarity."
        let result = scorer.score(spec)
        let cl1 = result.checks.first { $0.name == "what_no_ambiguity" }
        XCTAssertNotNil(cl1)
        XCTAssertTrue(cl1!.passed)
        XCTAssertEqual(cl1!.weight, 10)
    }

    // MARK: - Cycle 2: CL1 fails when 'what' contains vague words

    func test_cycle2_cl1_failsWhenWhatContainsVagueWords() {
        var spec = Spec(title: "CL1 vague")
        spec.sections.what = "We need to improve performance and make it faster for the entire application system."
        let result = scorer.score(spec)
        let cl1 = result.checks.first { $0.name == "what_no_ambiguity" }
        XCTAssertNotNil(cl1)
        XCTAssertFalse(cl1!.passed)
    }

    // MARK: - Cycle 3: CL2 passes when all ACs have non-empty given/when/then

    func test_cycle3_cl2_passesWithCompleteACs() {
        var spec = Spec(title: "CL2 complete")
        spec.sections.what = "This implementation adds a static scoring function that evaluates specification clarity."
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "a valid spec", when_: "score is computed", then_: "CL2 passes"),
            AcceptanceCriteria(given: "another context", when_: "another action", then_: "another result")
        ]
        let result = scorer.score(spec)
        let cl2 = result.checks.first { $0.name == "acceptance_gwt_format" }
        XCTAssertNotNil(cl2)
        XCTAssertTrue(cl2!.passed)
        XCTAssertEqual(cl2!.weight, 10)
    }

    // MARK: - Cycle 4: Cascade — CL1 = N/A when C1 fails (what < 50 chars)

    func test_cycle4_cascade_cl1_isNA_whenC1Fails() {
        var spec = Spec(title: "Cascade")
        spec.sections.what = "Too short"
        let result = scorer.score(spec)
        let cl1 = result.checks.first { $0.name == "what_no_ambiguity" }
        XCTAssertNotNil(cl1)
        XCTAssertFalse(cl1!.passed)
        XCTAssertTrue(cl1!.message.contains("N/A"))
        XCTAssertEqual(cl1!.weight, 0)
    }

    func test_cycle4_cascade_cl2_isNA_whenC3Fails() {
        var spec = Spec(title: "Cascade C3")
        spec.sections.what = "This implementation adds a static scoring function that evaluates specification clarity."
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "only one", when_: "one action", then_: "one result")
        ]
        let result = scorer.score(spec)
        let cl2 = result.checks.first { $0.name == "acceptance_gwt_format" }
        XCTAssertNotNil(cl2)
        XCTAssertFalse(cl2!.passed)
        XCTAssertTrue(cl2!.message.contains("N/A"))
        XCTAssertEqual(cl2!.weight, 0)
    }
}
