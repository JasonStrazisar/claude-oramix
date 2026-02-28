import XCTest
@testable import Claude_oramix

final class MockDataTests: XCTestCase {

    // Cycle 1: MockData.specs retourne exactement 5 specs
    func testSpecsCount() {
        XCTAssertEqual(MockData.specs.count, 5)
    }

    // Cycle 2: Le titre du premier mock correspond à MOCK_DATA.md
    func testFirstSpecTitle() {
        XCTAssertEqual(MockData.specs[0].title, "Add French locale to date formatter utility")
    }

    // Cycle 3: mock-004 (spec vague) a des tableaux where_ et acceptance vides
    func testMock004IsVague() {
        let mock004 = MockData.specs[3]
        XCTAssertTrue(mock004.sections.where_.isEmpty)
        XCTAssertTrue(mock004.sections.acceptance.isEmpty)
    }

    // Cycle 4: Tous les mocks ont un score SpecScore.empty
    func testAllSpecsHaveEmptyScore() {
        for spec in MockData.specs {
            XCTAssertEqual(spec.score.total, 0)
            XCTAssertEqual(spec.score.grade, .F)
            XCTAssertFalse(spec.score.isAgentReady)
            XCTAssertTrue(spec.score.checks.isEmpty)
            XCTAssertTrue(spec.score.suggestions.isEmpty)
        }
    }
}
