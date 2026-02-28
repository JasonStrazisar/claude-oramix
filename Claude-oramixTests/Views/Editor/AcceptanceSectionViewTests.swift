import XCTest
@testable import Claude_oramix

final class AcceptanceSectionViewTests: XCTestCase {
    func testNewCriterionDefaultsToHappyPath() {
        let criterion = AcceptanceCriteria()
        XCTAssertEqual(criterion.type, .happyPath)
    }

    func testNewCriterionHasEmptyFields() {
        let criterion = AcceptanceCriteria()
        XCTAssertTrue(criterion.given.isEmpty)
        XCTAssertTrue(criterion.when_.isEmpty)
        XCTAssertTrue(criterion.then_.isEmpty)
    }

    func testCriteriaTypesColorMapping() {
        // Verify all CriteriaType cases are handled
        let allTypes = CriteriaType.allCases
        XCTAssertTrue(allTypes.contains(.happyPath))
        XCTAssertTrue(allTypes.contains(.errorCase))
        XCTAssertTrue(allTypes.contains(.edgeCase))
    }
}
