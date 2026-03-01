import XCTest
import SwiftUI
@testable import Claude_oramix

final class SpecEditorViewTests: XCTestCase {
    func test_specEditorView_canBeInitialized() {
        var spec = Spec(title: "Test Spec")
        let binding = Binding(get: { spec }, set: { spec = $0 })
        let view = SpecEditorView(spec: binding, onDelete: { _ in })
        XCTAssertNotNil(view)
    }

    func test_onDelete_callbackIsCalled() {
        var spec = Spec(title: "Test")
        let binding = Binding(get: { spec }, set: { spec = $0 })
        var deletedId: UUID? = nil
        let view = SpecEditorView(spec: binding, onDelete: { id in deletedId = id })
        view.onDelete(spec.id)
        XCTAssertEqual(deletedId, spec.id)
    }

    // MARK: - Cycle 1: buildClaudeCommand

    func test_buildClaudeCommand_containsClaudeAndSpecTitle() {
        var spec = Spec(title: "My Feature Spec")
        let binding = Binding(get: { spec }, set: { spec = $0 })
        let view = SpecEditorView(spec: binding, onDelete: { _ in })
        let args = view.buildClaudeCommand(for: spec)
        XCTAssertEqual(args.first, "claude")
        XCTAssertTrue(args.contains(where: { $0.contains("My Feature Spec") }))
    }

    // MARK: - Cycle 2: buildClaudeCommand returns non-empty array

    func test_buildClaudeCommand_returnsNonEmptyArray() {
        var spec = Spec(title: "Test")
        spec.sections.what = "Do something useful"
        let binding = Binding(get: { spec }, set: { spec = $0 })
        let view = SpecEditorView(spec: binding, onDelete: { _ in })
        let args = view.buildClaudeCommand(for: spec)
        XCTAssertFalse(args.isEmpty)
        XCTAssertGreaterThan(args.count, 1)
    }
}
