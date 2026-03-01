import XCTest
@testable import Claude_oramix

final class MarkdownRendererTests: XCTestCase {

    // MARK: - Cycle 1: renders what

    func testRendersWhat() {
        var sections = SpecSections()
        sections.what = "Test feature description for testing"

        let html = MarkdownRenderer.renderHTML(sections: sections, score: nil)

        XCTAssertTrue(
            html.contains("Test feature description for testing"),
            "HTML should contain the what text"
        )
    }

    // MARK: - Cycle 2: renders score badge

    func testRendersScoreBadge() {
        let sections = SpecSections()
        let score = SpecScore(total: 95, grade: .A)

        let html = MarkdownRenderer.renderHTML(sections: sections, score: score)

        XCTAssertTrue(
            html.contains("95"),
            "HTML should contain the score total"
        )
    }

    // MARK: - Cycle 3: renders acceptance criteria

    func testRendersAcceptanceCriteria() {
        let criteria = AcceptanceCriteria(
            given: "A user",
            when_: "clicks",
            then_: "sees result"
        )
        let sections = SpecSections(acceptance: [criteria])

        let html = MarkdownRenderer.renderHTML(sections: sections, score: nil)

        XCTAssertTrue(html.contains("A user"), "HTML should contain given")
        XCTAssertTrue(html.contains("clicks"), "HTML should contain when")
        XCTAssertTrue(html.contains("sees result"), "HTML should contain then")
    }
}
