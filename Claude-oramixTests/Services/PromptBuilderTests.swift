import XCTest
@testable import Claude_oramix

final class PromptBuilderTests: XCTestCase {
    func makeSpec(title: String = "Test Spec") -> Spec {
        var spec = Spec(title: title)
        spec.sections.what = "This is a detailed description that explains what needs to be done."
        return spec
    }

    func testBuildReturnsNonEmptyString() {
        let spec = makeSpec()
        let output = PromptBuilder.build(from: spec)
        XCTAssertFalse(output.isEmpty)
    }

    func testBuildContainsTitle() {
        let spec = makeSpec(title: "My Amazing Feature")
        let output = PromptBuilder.build(from: spec)
        XCTAssertTrue(output.contains("My Amazing Feature"))
    }

    func testBuildContainsFilePaths() {
        var spec = makeSpec()
        spec.sections.where_ = [FileTarget(path: "Foo/Bar.swift", description: "Main file")]
        let output = PromptBuilder.build(from: spec)
        XCTAssertTrue(output.contains("Foo/Bar.swift"))
    }

    func testBuildContainsGivenWhenThen() {
        var spec = makeSpec()
        spec.sections.acceptance = [
            AcceptanceCriteria(given: "A user exists", when_: "They log in", then_: "They see the dashboard")
        ]
        let output = PromptBuilder.build(from: spec)
        XCTAssertTrue(output.contains("Given"))
        XCTAssertTrue(output.contains("When"))
        XCTAssertTrue(output.contains("Then"))
    }

    func testBuildOmitsContextWhenNil() {
        var spec = makeSpec()
        spec.sections.context = nil
        let output = PromptBuilder.build(from: spec)
        XCTAssertFalse(output.contains("## Context"))
    }

    func testBuildOmitsTechnicalNotesWhenNil() {
        var spec = makeSpec()
        spec.sections.technicalNotes = nil
        let output = PromptBuilder.build(from: spec)
        XCTAssertFalse(output.contains("## Technical Notes"))
    }

    func testBranchNameUsesShortcutId() {
        var spec = makeSpec(title: "Add French locale")
        spec.shortcutId = "SC-1234"
        let output = PromptBuilder.build(from: spec)
        XCTAssertTrue(output.contains("sc-SC-1234/"))
    }

    func testBranchNameUsesUUIDWhenNoShortcutId() {
        var spec = makeSpec(title: "Add Feature")
        spec.shortcutId = nil
        let output = PromptBuilder.build(from: spec)
        XCTAssertTrue(output.contains("sc-"))
        // UUID prefix (8 chars) should be in the branch
        XCTAssertTrue(output.contains(String(spec.id.uuidString.prefix(8))))
    }
}
