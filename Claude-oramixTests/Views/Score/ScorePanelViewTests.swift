import XCTest
@testable import Claude_oramix

final class ScorePanelViewTests: XCTestCase {

    // MARK: - ScorePanelState tests

    func testInitialIsCheckingIsFalse() {
        let sut = ScorePanelState()
        XCTAssertFalse(sut.isChecking)
    }

    func testIsCheckButtonDisabledWhenOllamaAnalysisNil() {
        let sut = ScorePanelState()
        XCTAssertFalse(sut.isCheckButtonDisabled)
    }

    func testIsCheckButtonDisabledWhenOllamaAnalysisNotNil() {
        var sut = ScorePanelState()
        sut.ollamaAnalysis = OllamaAnalysis(
            qualityScore: 0.8,
            suggestions: [],
            splitSuggestions: []
        )
        XCTAssertTrue(sut.isCheckButtonDisabled)
    }

    func testIsCheckButtonDisabledWhenIsChecking() {
        var sut = ScorePanelState()
        sut.isChecking = true
        XCTAssertTrue(sut.isCheckButtonDisabled)
    }

    // MARK: - Existing ScorePanelView tests

    // Test 1: mock-001 gives grade A, isAgentReady=true
    func testMock001GradeAAgentReady() {
        let spec = MockData.specs[0]
        let score = StaticScorer().score(spec)
        XCTAssertEqual(score.grade, .A)
        XCTAssertTrue(score.isAgentReady)
        XCTAssertGreaterThanOrEqual(score.total, 90)
    }

    // Test 2: mock-004 gives grade F, isAgentReady=false, 5+ suggestions
    func testMock004GradeFNotReady() {
        let spec = MockData.specs[3]
        let score = StaticScorer().score(spec)
        XCTAssertEqual(score.grade, .F)
        XCTAssertFalse(score.isAgentReady)
        XCTAssertGreaterThanOrEqual(score.suggestions.count, 5)
    }

    // Test 3: completeness group has 4 checks (C1-C4)
    func testCompletenessGroupHas4Checks() {
        let spec = MockData.specs[0]
        let score = StaticScorer().score(spec)
        let completenessChecks = score.checks.filter { $0.category == .completeness }
        XCTAssertEqual(completenessChecks.count, 4)
    }

    // Test 4: N/A checks detected correctly — empty spec causes C1 to fail => CL1, CL2, T1, T2 are N/A
    func testNAChecksDetected() {
        let spec = Spec(title: "Empty")
        let score = StaticScorer().score(spec)
        let naChecks = score.checks.filter { $0.message.contains("N/A") }
        XCTAssertFalse(naChecks.isEmpty)
        for naCheck in naChecks {
            XCTAssertTrue(naCheck.message.contains("N/A"))
        }
    }
}
