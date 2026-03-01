import XCTest
@testable import Claude_oramix

final class SpecStoreSplitTests: XCTestCase {

    // MARK: - Helpers

    private func makeTempDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
    }

    private func makeProposals(count: Int) -> [SplitProposal] {
        (1...count).map { i in
            SplitProposal(title: "Sub-spec \(i)", what: "What \(i)", estimate: 1)
        }
    }

    // MARK: - Cycle 1: createSubSpecs() retourne [Spec] avec le bon count

    func testCreateSubSpecsReturnsCorrectCount() {
        let tmpDir = makeTempDirectory()
        let store = SpecStore(directory: tmpDir)
        let parent = Spec(title: "Parent Spec")
        store.add(parent)

        let proposals = makeProposals(count: 3)
        let subSpecs = store.createSubSpecs(from: proposals, parent: parent)

        XCTAssertEqual(subSpecs.count, 3)
    }

    // MARK: - Cycle 2: Après createSubSpecs(), parent.status == .split

    func testCreateSubSpecsMarksParentAsSplit() {
        let tmpDir = makeTempDirectory()
        let store = SpecStore(directory: tmpDir)
        let parent = Spec(title: "Parent Spec")
        store.add(parent)

        let proposals = makeProposals(count: 3)
        store.createSubSpecs(from: proposals, parent: parent)

        let updatedParent = store.specs.first { $0.id == parent.id }
        XCTAssertEqual(updatedParent?.status, .split)
    }

    // MARK: - Titre vide → fallback non vide

    func testCreateSubSpecsWithEmptyTitleUsesFallback() {
        let tmpDir = makeTempDirectory()
        let store = SpecStore(directory: tmpDir)
        let parent = Spec(title: "Parent Spec")
        store.add(parent)

        let proposals = [SplitProposal(title: "", what: "Some content", estimate: 1)]
        let subSpecs = store.createSubSpecs(from: proposals, parent: parent)

        XCTAssertFalse(subSpecs[0].title.isEmpty)
    }
}
