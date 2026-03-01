import XCTest
@testable import Claude_oramix

final class ProjectStoreTests: XCTestCase {

    // MARK: - Helpers

    private func makeTempDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
    }

    private func makeProject(name: String = "MyApp", path: String = "/tmp/myapp") -> Project {
        Project(name: name, path: path)
    }

    // MARK: - Cycle 1: Initial state

    func testProjectStoreInitialState() {
        let tmpDir = makeTempDirectory()
        let store = ProjectStore(directory: tmpDir)
        XCTAssertTrue(store.projects.isEmpty)
        XCTAssertNil(store.activeProjectId)
    }

    // MARK: - Cycle 2: add() persists to disk

    func testAddProjectPersists() {
        let tmpDir = makeTempDirectory()
        let store = ProjectStore(directory: tmpDir)
        let project = makeProject()
        store.add(project)

        let store2 = ProjectStore(directory: tmpDir)
        store2.load()
        XCTAssertEqual(store2.projects.count, 1)
        XCTAssertEqual(store2.projects[0].id, project.id)

        let jsonURL = tmpDir.appendingPathComponent("projects.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: jsonURL.path))
    }

    // MARK: - Cycle 3: SpecStore(projectId:) uses correct path

    func testSpecStoreUsesProjectDirectory() {
        let tmpDir = makeTempDirectory()
        let uuid = UUID()
        let store = SpecStore(projectId: uuid, baseDirectory: tmpDir)
        XCTAssertTrue(store.fileURL.path.contains("projects/"))
        XCTAssertTrue(store.fileURL.path.contains(uuid.uuidString))
    }

    // MARK: - Edge case: load() without file returns empty without crash

    func testLoadEmptyWhenNoFileExists() {
        let tmpDir = makeTempDirectory()
        let store = ProjectStore(directory: tmpDir)
        store.load()
        XCTAssertTrue(store.projects.isEmpty)
    }
}
