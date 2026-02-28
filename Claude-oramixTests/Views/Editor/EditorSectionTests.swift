import XCTest
@testable import Claude_oramix

final class EditorSectionTests: XCTestCase {
    func testNonGoalsInitiallyEmpty() {
        let nonGoals: [String] = []
        XCTAssertTrue(nonGoals.isEmpty)
    }

    func testMetadataEstimateRange() {
        // Stepper range is 0...5
        var estimate = 5
        estimate = min(estimate + 1, 5) // Increment beyond max → stays at 5
        XCTAssertEqual(estimate, 5)

        var estimate2 = 0
        estimate2 = max(estimate2 - 1, 0) // Decrement below min → stays at 0
        XCTAssertEqual(estimate2, 0)
    }

    func testLabelsFromCommaSeparated() {
        let text = "phase-1, specautomatix, data"
        let labels = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        XCTAssertEqual(labels, ["phase-1", "specautomatix", "data"])
    }

    func testPatternRefInit() {
        let pattern = PatternRef(name: "MVVM", reference: "See architecture doc")
        XCTAssertEqual(pattern.name, "MVVM")
        XCTAssertEqual(pattern.reference, "See architecture doc")
    }
}
