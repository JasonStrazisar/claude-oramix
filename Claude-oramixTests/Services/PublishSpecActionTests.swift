import XCTest
@testable import Claude_oramix

// MARK: - MockPublishProvider

final class MockPublishProvider: IssueTrackerProvider {
    var createIssueCalled = false
    var addCommentCalled = false
    var urlToReturn = "https://github.com/owner/repo/issues/1"
    var numberToReturn = 1
    var shouldThrow: IssueTrackerError? = nil

    func createIssue(title: String, body: String) async throws -> CreatedIssue {
        if let error = shouldThrow { throw error }
        createIssueCalled = true
        return CreatedIssue(url: urlToReturn, number: numberToReturn)
    }

    func addComment(issueNumber: Int, body: String) async throws {
        if let error = shouldThrow { throw error }
        addCommentCalled = true
    }
}

// MARK: - MockSpecStore

final class MockSpecStore: SpecStore {
    var updatedSpec: Spec?

    init() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        super.init(directory: tempDir)
    }

    override func update(_ spec: Spec) {
        updatedSpec = spec
    }
}

// MARK: - Helpers

private func makeSpec(score: Int = 90) -> Spec {
    var spec = Spec(title: "Test Spec")
    spec.score = SpecScore(total: score, grade: .A, checks: [], suggestions: [], isAgentReady: true)
    return spec
}

private func makeProject() -> Project {
    Project(
        name: "Test Project",
        path: "/tmp/test",
        issueTracker: IssueTrackerConfig(type: "github", baseURL: "https://github.com", projectKey: "owner/repo")
    )
}

// MARK: - PublishSpecActionTests

final class PublishSpecActionTests: XCTestCase {

    // MARK: - Cycle 1 : execute() appelle createIssue() et addComment()

    func testPublishCallsCreateAndComment() async throws {
        let mock = MockPublishProvider()
        let spec = makeSpec(score: 90)
        let project = makeProject()
        let store = MockSpecStore()

        let action = PublishSpecAction()
        _ = try await action.execute(spec: spec, project: project, provider: mock, store: store)

        XCTAssertTrue(mock.createIssueCalled)
        XCTAssertTrue(mock.addCommentCalled)
    }

    // MARK: - Cycle 2 : execute() retourne l'URL

    func testPublishReturnsIssueUrl() async throws {
        let mock = MockPublishProvider()
        mock.urlToReturn = "https://github.com/owner/repo/issues/1"
        let spec = makeSpec(score: 90)
        let project = makeProject()
        let store = MockSpecStore()

        let action = PublishSpecAction()
        let url = try await action.execute(spec: spec, project: project, provider: mock, store: store)

        XCTAssertEqual(url, "https://github.com/owner/repo/issues/1")
    }

    // MARK: - Cycle 3 : spec.issueRef est mis à jour

    func testPublishUpdatesIssueRef() async throws {
        let mock = MockPublishProvider()
        mock.urlToReturn = "https://github.com/owner/repo/issues/42"
        mock.numberToReturn = 42
        let spec = makeSpec(score: 90)
        let project = makeProject()
        let store = MockSpecStore()

        let action = PublishSpecAction()
        _ = try await action.execute(spec: spec, project: project, provider: mock, store: store)

        XCTAssertEqual(store.updatedSpec?.issueRef, "https://github.com/owner/repo/issues/42")
    }
}
