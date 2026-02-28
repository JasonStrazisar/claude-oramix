import XCTest
import SwiftUI
@testable import Claude_oramix

final class SpecSidebarTests: XCTestCase {

    // MARK: - ScoreBadgeView color tests (theme colors)

    func test_scoreBadge_gradeAIsThemeGreen() {
        XCTAssertEqual(ScoreBadgeView.color(for: .A), Color.theme.textColor(for: .A))
    }

    func test_scoreBadge_gradeBIsThemeBlue() {
        XCTAssertEqual(ScoreBadgeView.color(for: .B), Color.theme.textColor(for: .B))
    }

    func test_scoreBadge_gradeCIsThemeAmber() {
        XCTAssertEqual(ScoreBadgeView.color(for: .C), Color.theme.textColor(for: .C))
    }

    func test_scoreBadge_gradeDIsThemeRose() {
        XCTAssertEqual(ScoreBadgeView.color(for: .D), Color.theme.textColor(for: .D))
    }

    func test_scoreBadge_gradeFIsThemeStone() {
        XCTAssertEqual(ScoreBadgeView.color(for: .F), Color.theme.textColor(for: .F))
    }

    func test_scoreBadge_colorsAreDistinct() {
        let grades: [ScoreGrade] = [.A, .B, .C, .D, .F]
        let colors = grades.map { ScoreBadgeView.color(for: $0) }
        // Each grade should have a unique color
        let unique = Set(colors.map { "\($0)" })
        XCTAssertEqual(unique.count, grades.count)
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
