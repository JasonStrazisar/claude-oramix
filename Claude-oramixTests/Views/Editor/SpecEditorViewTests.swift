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
}
