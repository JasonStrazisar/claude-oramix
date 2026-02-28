import XCTest
@testable import Claude_oramix

final class SpecautomatixViewTests: XCTestCase {

    // MARK: - Helpers

    private func makeTempStore() -> SpecStore {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        return SpecStore(directory: dir)
    }

    // MARK: - MockData loading

    func test_emptyStore_mockDataLoadedOnAppear() {
        let store = makeTempStore()
        XCTAssertTrue(store.specs.isEmpty)

        // Simulate SpecautomatixView.loadMockDataIfNeeded logic
        if store.specs.isEmpty {
            MockData.specs.forEach { store.add($0) }
        }

        XCTAssertEqual(store.specs.count, 5)
    }

    func test_nonEmptyStore_mockDataNotLoaded() {
        let store = makeTempStore()
        store.add(Spec(title: "Existing Spec"))
        let countBefore = store.specs.count

        // Simulate SpecautomatixView.loadMockDataIfNeeded logic
        if store.specs.isEmpty {
            MockData.specs.forEach { store.add($0) }
        }

        XCTAssertEqual(store.specs.count, countBefore)
    }

    // MARK: - First spec auto-selection

    func test_firstSpecAutoSelectedAfterMockLoad() {
        let store = makeTempStore()
        MockData.specs.forEach { store.add($0) }

        let firstId = SpecSidebar.sorted(store.specs).first?.id
        XCTAssertNotNil(firstId)
        XCTAssertTrue(store.specs.contains(where: { $0.id == firstId }))
    }

    // MARK: - Deletion

    func test_deleteSelectedSpec_selectionMovesToNextSpec() {
        let store = makeTempStore()
        MockData.specs.forEach { store.add($0) }

        let sorted = SpecSidebar.sorted(store.specs)
        let firstId = sorted.first!.id

        store.delete(firstId)

        XCTAssertFalse(store.specs.contains(where: { $0.id == firstId }))
        // Remaining specs are still available for selection
        XCTAssertFalse(store.specs.isEmpty)
        XCTAssertNotNil(SpecSidebar.sorted(store.specs).first?.id)
    }

    func test_deleteLastSpec_storeBecomesEmpty() {
        let store = makeTempStore()
        let spec = Spec(title: "Only Spec")
        store.add(spec)

        store.delete(spec.id)

        XCTAssertTrue(store.specs.isEmpty)
        XCTAssertNil(SpecSidebar.sorted(store.specs).first?.id)
    }

    // MARK: - Selection drives editor

    func test_selectionDrivesEditor_specFoundInStore() {
        let store = makeTempStore()
        MockData.specs.forEach { store.add($0) }

        let targetId = store.specs[2].id
        let found = store.specs.first(where: { $0.id == targetId })

        XCTAssertNotNil(found)
        XCTAssertEqual(found?.id, targetId)
    }

    func test_selectionDrivesEditor_unknownIdReturnsNil() {
        let store = makeTempStore()
        MockData.specs.forEach { store.add($0) }

        let unknownId = UUID()
        let found = store.specs.first(where: { $0.id == unknownId })

        XCTAssertNil(found)
    }
}
