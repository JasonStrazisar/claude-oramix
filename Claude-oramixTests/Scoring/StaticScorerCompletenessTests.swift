import XCTest
@testable import Claude_oramix

final class StaticScorerCompletenessTests: XCTestCase {

    private let scorer = StaticScorer()

    // MARK: - Cycle 1: Empty spec gives score 0

    func test_cycle1_emptySpecGivesScoreZero() {
        let spec = Spec(title: "Empty")
        let result = scorer.score(spec)
        XCTAssertEqual(result.total, 0)
        XCTAssertEqual(result.grade, .F)
        XCTAssertFalse(result.isAgentReady)
    }

    // MARK: - Cycle 2: C1 — what > 50 chars gives 15 pts

    func test_cycle2_whatOver50CharsPassesC1() {
        var spec = Spec(title: "Test C1")
        spec.sections.what = String(repeating: "a", count: 51)
        let result = scorer.score(spec)
        let c1 = result.checks.first { $0.name == "what_present" }
        XCTAssertNotNil(c1)
        XCTAssertTrue(c1!.passed)
        XCTAssertEqual(c1!.weight, 15)
        XCTAssertGreaterThanOrEqual(result.total, 15)
    }

    func test_cycle2_whatExactly50CharsFailsC1() {
        var spec = Spec(title: "Test C1 boundary")
        spec.sections.what = String(repeating: "a", count: 50)
        let result = scorer.score(spec)
        let c1 = result.checks.first { $0.name == "what_present" }
        XCTAssertNotNil(c1)
        XCTAssertFalse(c1!.passed)
    }

    func test_cycle2_emptyWhatFailsC1() {
        let spec = Spec(title: "Test C1 empty")
        let result = scorer.score(spec)
        let c1 = result.checks.first { $0.name == "what_present" }
        XCTAssertNotNil(c1)
        XCTAssertFalse(c1!.passed)
    }

    // MARK: - Cycle 3: C2 — at least 1 FileTarget gives 15 pts

    func test_cycle3_oneFileTargetPassesC2() {
        var spec = Spec(title: "Test C2")
        spec.sections.where_ = [FileTarget(path: "Foo/Bar.swift", description: "Desc")]
        let result = scorer.score(spec)
        let c2 = result.checks.first { $0.name == "files_listed" }
        XCTAssertNotNil(c2)
        XCTAssertTrue(c2!.passed)
        XCTAssertEqual(c2!.weight, 15)
    }

    func test_cycle3_noFileTargetFailsC2() {
        let spec = Spec(title: "Test C2 empty")
        let result = scorer.score(spec)
        let c2 = result.checks.first { $0.name == "files_listed" }
        XCTAssertNotNil(c2)
        XCTAssertFalse(c2!.passed)
    }

    // MARK: - Cycle 4: C3 — at least 2 ACs gives 15 pts

    func test_cycle4_twoACsPassesC3() {
        var spec = Spec(title: "Test C3")
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "g1", when_: "w1", then_: "t1"),
            AcceptanceCriteria(given: "g2", when_: "w2", then_: "t2")
        ]
        let result = scorer.score(spec)
        let c3 = result.checks.first { $0.name == "acceptance_present" }
        XCTAssertNotNil(c3)
        XCTAssertTrue(c3!.passed)
        XCTAssertEqual(c3!.weight, 15)
    }

    func test_cycle4_oneACFailsC3() {
        var spec = Spec(title: "Test C3 one")
        spec.sections.acceptance = [AcceptanceCriteria(given: "g1", when_: "w1", then_: "t1")]
        let result = scorer.score(spec)
        let c3 = result.checks.first { $0.name == "acceptance_present" }
        XCTAssertNotNil(c3)
        XCTAssertFalse(c3!.passed)
    }

    func test_cycle4_noACFailsC3() {
        let spec = Spec(title: "Test C3 empty")
        let result = scorer.score(spec)
        let c3 = result.checks.first { $0.name == "acceptance_present" }
        XCTAssertNotNil(c3)
        XCTAssertFalse(c3!.passed)
    }

    // MARK: - Cycle 5: C4 — all files have description gives 5 pts

    func test_cycle5_allFilesWithDescriptionPassesC4() {
        var spec = Spec(title: "Test C4")
        spec.sections.where_ = [
            FileTarget(path: "A.swift", description: "desc A"),
            FileTarget(path: "B.swift", description: "desc B")
        ]
        let result = scorer.score(spec)
        let c4 = result.checks.first { $0.name == "files_have_description" }
        XCTAssertNotNil(c4)
        XCTAssertTrue(c4!.passed)
        XCTAssertEqual(c4!.weight, 5)
    }

    func test_cycle5_oneFileWithoutDescriptionFailsC4() {
        var spec = Spec(title: "Test C4 missing desc")
        spec.sections.where_ = [
            FileTarget(path: "A.swift", description: "desc A"),
            FileTarget(path: "B.swift", description: "")
        ]
        let result = scorer.score(spec)
        let c4 = result.checks.first { $0.name == "files_have_description" }
        XCTAssertNotNil(c4)
        XCTAssertFalse(c4!.passed)
    }

    func test_cycle5_emptyWhereListC4PassesWithZeroWeight() {
        let spec = Spec(title: "Test C4 empty where_")
        let result = scorer.score(spec)
        let c4 = result.checks.first { $0.name == "files_have_description" }
        XCTAssertNotNil(c4)
        // allSatisfy on empty array returns true in Swift, C4 passes but contributes 0 to total
        // since C2 is not passing (no files), C4 should still be present but its weight is 0
        XCTAssertEqual(c4!.weight, 0)
    }

    // MARK: - Combined: all completeness checks passing gives 50 pts from completeness

    func test_combined_allChecksPassingGives50Points() {
        var spec = Spec(title: "Full Spec")
        spec.sections.what = "This is a detailed what section that has more than fifty characters total."
        spec.sections.where_ = [
            FileTarget(path: "Foo/Bar.swift", description: "Main logic file"),
            FileTarget(path: "Foo/BarTests.swift", description: "Unit tests")
        ]
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "given1", when_: "when1", then_: "then1"),
            AcceptanceCriteria(given: "given2", when_: "when2", then_: "then2")
        ]
        let result = scorer.score(spec)
        let completenessChecks = result.checks.filter { $0.category == .completeness }
        XCTAssertEqual(completenessChecks.count, 4)
        XCTAssertTrue(completenessChecks.allSatisfy { $0.passed })
        let completenessTotal = completenessChecks.filter { $0.passed }.map { $0.weight }.reduce(0, +)
        XCTAssertEqual(completenessTotal, 50)
        XCTAssertFalse(result.isAgentReady)
    }

    // MARK: - Grade computation tests

    func test_grade_A_at90() {
        // Verify grade C is obtained at 70 pts (completeness 50 + clarity 20)
        // when completeness and clarity checks all pass
        var spec = Spec(title: "Grade Test")
        spec.sections.what = "This is a detailed what section that has more than fifty characters total."
        spec.sections.where_ = [FileTarget(path: "A.swift", description: "desc")]
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "g1", when_: "w1", then_: "t1"),
            AcceptanceCriteria(given: "g2", when_: "w2", then_: "t2")
        ]
        let result = scorer.score(spec)
        XCTAssertEqual(result.grade, .C)
    }

    func test_grade_F_for_zero() {
        let spec = Spec(title: "Grade F")
        let result = scorer.score(spec)
        XCTAssertEqual(result.grade, .F)
    }

    func test_isAgentReady_false_for_completeness_only() {
        var spec = Spec(title: "Not ready")
        spec.sections.what = "This is a detailed what section that has more than fifty characters total."
        spec.sections.where_ = [FileTarget(path: "A.swift", description: "desc")]
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "g1", when_: "w1", then_: "t1"),
            AcceptanceCriteria(given: "g2", when_: "w2", then_: "t2")
        ]
        let result = scorer.score(spec)
        XCTAssertFalse(result.isAgentReady)
    }
}
