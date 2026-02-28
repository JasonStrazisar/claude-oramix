import XCTest
@testable import Claude_oramix

final class SpecSidebarTests: XCTestCase {

    // MARK: - ScoreBadgeView color tests

    func test_scoreBadge_gradeAIsGreen() {
        XCTAssertEqual(ScoreBadgeView.color(for: .A), .green)
    }

    func test_scoreBadge_gradeBIsBlue() {
        XCTAssertEqual(ScoreBadgeView.color(for: .B), .blue)
    }

    func test_scoreBadge_gradeCIsOrange() {
        XCTAssertEqual(ScoreBadgeView.color(for: .C), .orange)
    }

    func test_scoreBadge_gradeDIsRed() {
        XCTAssertEqual(ScoreBadgeView.color(for: .D), .red)
    }

    func test_scoreBadge_gradeFIsGray() {
        XCTAssertEqual(ScoreBadgeView.color(for: .F), .gray)
    }

    // MARK: - SpecSidebar sorting tests

    func test_specs_sortedByUpdatedAtDescending() {
        let now = Date()
        var spec1 = Spec(title: "Older")
        var spec2 = Spec(title: "Newer")
        var spec3 = Spec(title: "Middle")

        spec1.updatedAt = now.addingTimeInterval(-200)
        spec2.updatedAt = now.addingTimeInterval(0)
        spec3.updatedAt = now.addingTimeInterval(-100)

        let sorted = SpecSidebar.sorted([spec1, spec2, spec3])

        XCTAssertEqual(sorted[0].title, "Newer")
        XCTAssertEqual(sorted[1].title, "Middle")
        XCTAssertEqual(sorted[2].title, "Older")
    }
}
