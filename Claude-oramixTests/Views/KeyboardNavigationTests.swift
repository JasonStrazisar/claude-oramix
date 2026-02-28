import XCTest
@testable import Claude_oramix

final class KeyboardNavigationTests: XCTestCase {

    // MARK: - Filter logic

    func test_filter_emptyQuery_returnsAllSpecs() {
        let specs = [makeSpec("Alpha"), makeSpec("Beta"), makeSpec("French")]
        let result = filterSpecs(specs, query: "")
        XCTAssertEqual(result.count, 3)
    }

    func test_filter_queryMatch_returnsOnlyMatchingSpecs() {
        let specs = [makeSpec("Alpha"), makeSpec("Beta"), makeSpec("French Menu")]
        let result = filterSpecs(specs, query: "French")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].title, "French Menu")
    }

    func test_filter_queryNoMatch_returnsEmpty() {
        let specs = [makeSpec("Alpha"), makeSpec("Beta")]
        let result = filterSpecs(specs, query: "xyz")
        XCTAssertTrue(result.isEmpty)
    }

    func test_filter_caseInsensitive() {
        let specs = [makeSpec("French Menu"), makeSpec("Other")]
        let result = filterSpecs(specs, query: "french")
        XCTAssertEqual(result.count, 1)
    }

    // MARK: - Navigation: selectNext (AC-1)

    func test_selectNext_from2nd_movesTo3rd() {
        let specs = [makeSpec("A"), makeSpec("B"), makeSpec("C")]
        let newId = nextSpec(in: specs, currentId: specs[1].id)
        XCTAssertEqual(newId, specs[2].id)
    }

    func test_selectNext_atBottom_staysAtBottom() {
        let specs = [makeSpec("A"), makeSpec("B"), makeSpec("C")]
        let newId = nextSpec(in: specs, currentId: specs[2].id)
        XCTAssertEqual(newId, specs[2].id)
    }

    // MARK: - Navigation: selectPrevious (AC-2)

    func test_selectPrevious_atTop_staysAtTop() {
        let specs = [makeSpec("A"), makeSpec("B"), makeSpec("C")]
        let newId = previousSpec(in: specs, currentId: specs[0].id)
        XCTAssertEqual(newId, specs[0].id)
    }

    func test_selectPrevious_from2nd_movesTo1st() {
        let specs = [makeSpec("A"), makeSpec("B"), makeSpec("C")]
        let newId = previousSpec(in: specs, currentId: specs[1].id)
        XCTAssertEqual(newId, specs[0].id)
    }

    // MARK: - Create new spec (AC-3)

    func test_createNewSpec_addsToStore() {
        let store = SpecStore()
        let initialCount = store.specs.count
        store.add(Spec(title: "New Spec"))
        XCTAssertEqual(store.specs.count, initialCount + 1)
    }

    func test_createNewSpec_hasCorrectTitle() {
        let store = SpecStore()
        let newSpec = Spec(title: "New Spec")
        store.add(newSpec)
        XCTAssertEqual(store.specs.last(where: { $0.id == newSpec.id })?.title, "New Spec")
    }

    // MARK: - Helpers

    private func makeSpec(_ title: String) -> Spec {
        Spec(title: title)
    }

    private func filterSpecs(_ specs: [Spec], query: String) -> [Spec] {
        guard !query.isEmpty else { return specs }
        return specs.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private func nextSpec(in specs: [Spec], currentId: UUID) -> UUID? {
        guard let index = specs.firstIndex(where: { $0.id == currentId }) else { return nil }
        return specs[min(index + 1, specs.count - 1)].id
    }

    private func previousSpec(in specs: [Spec], currentId: UUID) -> UUID? {
        guard let index = specs.firstIndex(where: { $0.id == currentId }) else { return nil }
        return specs[max(index - 1, 0)].id
    }
}
