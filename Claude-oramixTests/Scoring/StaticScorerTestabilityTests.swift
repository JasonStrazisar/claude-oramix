import XCTest
@testable import Claude_oramix

final class StaticScorerTestabilityTests: XCTestCase {

    private let scorer = StaticScorer()

    // MARK: - Helper

    private func makeValidSpec() -> Spec {
        var spec = Spec(title: "Valid Spec")
        spec.sections.what = "This is a detailed what section that has more than fifty characters total."
        spec.sections.where_ = [
            FileTarget(path: "Foo/Bar.swift", description: "Main logic"),
            FileTarget(path: "Foo/BarTests.swift", description: "Unit tests")
        ]
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "g1", when_: "w1", then_: "Returns 200", type: .happyPath),
            AcceptanceCriteria(given: "g2", when_: "w2", then_: "Returns 404", type: .errorCase)
        ]
        return spec
    }

    // MARK: - Cycle 1: T1 passes with 1 happyPath + 1 errorCase

    func test_cycle1_t1PassesWithMixedTypes() {
        var spec = makeValidSpec()
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "g1", when_: "w1", then_: "Returns 200", type: .happyPath),
            AcceptanceCriteria(given: "g2", when_: "w2", then_: "Returns 404", type: .errorCase)
        ]
        let result = StaticScorer().score(spec)
        let t1 = result.checks.first { $0.name == "acceptance_types_covered" }
        XCTAssertNotNil(t1)
        XCTAssertTrue(t1!.passed)
        XCTAssertEqual(t1!.weight, 10)
    }

    // MARK: - Cycle 2: T1 fails with only happyPaths

    func test_cycle2_t1FailsWithOnlyHappyPaths() {
        var spec = makeValidSpec()
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "g1", when_: "w1", then_: "t1", type: .happyPath),
            AcceptanceCriteria(given: "g2", when_: "w2", then_: "t2", type: .happyPath)
        ]
        let result = StaticScorer().score(spec)
        let t1 = result.checks.first { $0.name == "acceptance_types_covered" }
        XCTAssertNotNil(t1)
        XCTAssertFalse(t1!.passed)
    }

    // MARK: - Cycle 3: T2 passes with concrete then_ fields

    func test_cycle3_t2PassesWithConcreteThens() {
        var spec = makeValidSpec()
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "g1", when_: "w1", then_: "Returns '15/03/2025'", type: .happyPath),
            AcceptanceCriteria(given: "g2", when_: "w2", then_: "Displays error 'Invalid input'", type: .errorCase)
        ]
        let result = StaticScorer().score(spec)
        let t2 = result.checks.first { $0.name == "acceptance_measurable" }
        XCTAssertNotNil(t2)
        XCTAssertTrue(t2!.passed)
        XCTAssertEqual(t2!.weight, 5)
    }

    // MARK: - Cycle 4: T2 fails when then_ contains "should work"

    func test_cycle4_t2FailsWithVagueThen() {
        var spec = makeValidSpec()
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "g1", when_: "w1", then_: "It should work correctly", type: .happyPath),
            AcceptanceCriteria(given: "g2", when_: "w2", then_: "Returns 404", type: .errorCase)
        ]
        let result = StaticScorer().score(spec)
        let t2 = result.checks.first { $0.name == "acceptance_measurable" }
        XCTAssertNotNil(t2)
        XCTAssertFalse(t2!.passed)
    }

    // MARK: - Cascade: T1 and T2 are N/A when C3 fails

    func test_cascade_t1t2AreNAWhenC3Fails() {
        var spec = makeValidSpec()
        spec.sections.acceptance = [] // C3 fail
        let result = StaticScorer().score(spec)
        let t1 = result.checks.first { $0.name == "acceptance_types_covered" }
        let t2 = result.checks.first { $0.name == "acceptance_measurable" }
        XCTAssertNotNil(t1)
        XCTAssertNotNil(t2)
        XCTAssertFalse(t1!.passed)
        XCTAssertFalse(t2!.passed)
        XCTAssertTrue(t1!.message.contains("N/A"))
        XCTAssertTrue(t2!.message.contains("N/A"))
    }
}
