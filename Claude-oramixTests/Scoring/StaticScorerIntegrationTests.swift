import XCTest
@testable import Claude_oramix

final class StaticScorerIntegrationTests: XCTestCase {

    private let scorer = StaticScorer()

    // MARK: - Cycle 1: Score 0 → grade .F, isAgentReady = false

    func test_cycle1_emptySpecGradeF_isAgentReadyFalse() {
        let spec = Spec(title: "Empty")
        let result = scorer.score(spec)
        XCTAssertEqual(result.grade, .F)
        XCTAssertFalse(result.isAgentReady)
    }

    // MARK: - Cycle 2: Score ≥ 80 → grade ≥ .B, isAgentReady = true

    func test_cycle2_fullSpecGradeAorB_isAgentReadyTrue() {
        let result = scorer.score(MockData.specs[0])
        XCTAssertGreaterThanOrEqual(result.total, 80)
        XCTAssertTrue(result.grade == .A || result.grade == .B)
        XCTAssertTrue(result.isAgentReady)
    }

    // MARK: - Cycle 3: Total capped at 100

    func test_cycle3_totalCappedAt100() {
        let result = scorer.score(MockData.specs[0])
        XCTAssertLessThanOrEqual(result.total, 100)
    }

    // MARK: - Cycle 4: Suggestions generated from failing checks

    func test_cycle4_specWithoutAcceptanceCriteria_hasSuggestions() {
        var spec = Spec(title: "No ACs")
        spec.sections.what = String(repeating: "a", count: 51)
        spec.sections.where_ = [FileTarget(path: "src/foo.ts", description: "desc")]
        // acceptance is empty → C3 fails
        let result = scorer.score(spec)
        XCTAssertFalse(result.suggestions.isEmpty, "Suggestions should not be empty when checks fail")
        let hasAcceptanceSuggestion = result.suggestions.contains { $0.contains("acceptance") || $0.contains("critère") }
        XCTAssertTrue(hasAcceptanceSuggestion, "Expected a suggestion about missing acceptance criteria")
    }

    // MARK: - Cycle 5: MockData.specs[3] (mock-004) scores 0

    func test_cycle5_mock004_scoresTotalZero() {
        let result = scorer.score(MockData.specs[3])
        XCTAssertEqual(result.total, 0)
    }

    // MARK: - Integration: all 5 mock specs

    func test_integration_mock001_gradeA() {
        let result = scorer.score(MockData.specs[0])
        XCTAssertEqual(result.grade, .A, "mock-001 doit avoir le grade A (total >= 90)")
        XCTAssertGreaterThanOrEqual(result.total, 90)
        XCTAssertTrue(result.isAgentReady)
    }

    func test_integration_mock002_gradeB() {
        let result = scorer.score(MockData.specs[1])
        XCTAssertEqual(result.grade, .B, "mock-002 doit avoir le grade B (80-89)")
        XCTAssertTrue(result.isAgentReady)
        let mentionsPatterns = result.suggestions.contains { $0.lowercased().contains("pattern") }
        XCTAssertTrue(mentionsPatterns, "mock-002 doit suggérer d'ajouter des patterns")
    }

    func test_integration_mock003_gradeCOrD() {
        let result = scorer.score(MockData.specs[2])
        XCTAssertTrue(result.grade == .C || result.grade == .D, "mock-003 doit avoir le grade C ou D")
        XCTAssertFalse(result.isAgentReady)
    }

    func test_integration_mock004_gradeF_suggestions() {
        let result = scorer.score(MockData.specs[3])
        XCTAssertEqual(result.grade, .F)
        XCTAssertFalse(result.isAgentReady)
        XCTAssertEqual(result.total, 0)
        XCTAssertGreaterThanOrEqual(result.suggestions.count, 5, "mock-004 doit avoir au moins 5 suggestions")
    }

    func test_integration_mock005_agentReady() {
        let result = scorer.score(MockData.specs[4])
        XCTAssertTrue(result.isAgentReady, "mock-005 doit être agent-ready")
    }

    // MARK: - Edge case: cascade CL1 references C1 prerequisite

    func test_cascade_cl1SuggestionReferencesC1() {
        // Spec with C1 failing → CL1 cascades
        let spec = Spec(title: "Short what")
        // what is empty → C1 fails → CL1 should cascade
        let result = scorer.score(spec)
        let cl1Suggestion = result.suggestions.first { $0.contains("CL1") }
        XCTAssertNotNil(cl1Suggestion, "Should have a CL1 cascade suggestion")
        let referencesC1 = cl1Suggestion?.contains("C1") ?? false
        XCTAssertTrue(referencesC1, "CL1 cascade suggestion must reference C1 prerequisite")
    }
}
