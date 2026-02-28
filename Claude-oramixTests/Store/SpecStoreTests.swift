import XCTest
@testable import Claude_oramix

final class SpecStoreTests: XCTestCase {

    // MARK: - Helpers

    private func makeTempDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
    }

    private func makeSpec(title: String = "Test Spec") -> Spec {
        Spec(title: title)
    }

    // MARK: - Cycle 1: Empty load when no file exists

    func testLoadEmptyWhenNoFileExists() {
        let tmpDir = makeTempDirectory()
        let store = SpecStore(directory: tmpDir)
        store.load()
        XCTAssertTrue(store.specs.isEmpty)
    }

    // MARK: - Cycle 2: add() persists and second store can load it

    func testAddPersistsSpecToDisk() {
        let tmpDir = makeTempDirectory()
        let store = SpecStore(directory: tmpDir)
        let spec = makeSpec(title: "Persisted Spec")
        store.add(spec)

        let store2 = SpecStore(directory: tmpDir)
        store2.load()
        XCTAssertEqual(store2.specs.count, 1)
        XCTAssertEqual(store2.specs[0].id, spec.id)
    }

    // MARK: - Cycle 3: delete() removes spec by id

    func testDeleteRemovesSpecById() {
        let tmpDir = makeTempDirectory()
        let store = SpecStore(directory: tmpDir)
        let spec1 = makeSpec(title: "Spec 1")
        let spec2 = makeSpec(title: "Spec 2")
        let spec3 = makeSpec(title: "Spec 3")
        store.add(spec1)
        store.add(spec2)
        store.add(spec3)

        store.delete(spec2.id)

        XCTAssertEqual(store.specs.count, 2)
        XCTAssertFalse(store.specs.contains(where: { $0.id == spec2.id }))
    }

    // MARK: - Cycle 4: update() replaces spec by id without changing count

    func testUpdateReplacesSpecById() {
        let tmpDir = makeTempDirectory()
        let store = SpecStore(directory: tmpDir)
        var spec = makeSpec(title: "Original Title")
        store.add(spec)

        spec.title = "Updated Title"
        store.update(spec)

        XCTAssertEqual(store.specs.count, 1)
        XCTAssertEqual(store.specs[0].title, "Updated Title")
    }

    // MARK: - Cycle 5: load() with malformed JSON returns empty array without crash

    func testLoadMalformedJSONReturnsEmpty() throws {
        let tmpDir = makeTempDirectory()
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        let fileURL = tmpDir.appendingPathComponent("specs.json")
        try "INVALID".write(to: fileURL, atomically: true, encoding: .utf8)

        let store = SpecStore(directory: tmpDir)
        store.load()

        XCTAssertTrue(store.specs.isEmpty)
    }
}
