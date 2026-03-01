import XCTest
@testable import Claude_oramix

// MARK: - Mock

private final class MockIssueTrackerProvider: IssueTrackerProvider {
    var createIssueCalled = false
    var addCommentCalled = false
    var shouldThrow: IssueTrackerError?

    func createIssue(title: String, body: String) async throws -> CreatedIssue {
        createIssueCalled = true
        if let error = shouldThrow { throw error }
        return CreatedIssue(url: "https://github.com/org/repo/issues/1", number: 1)
    }

    func addComment(issueNumber: Int, body: String) async throws {
        addCommentCalled = true
        if let error = shouldThrow { throw error }
    }
}

// MARK: - Tests

final class IssueTrackerProviderTests: XCTestCase {

    // Cycle 1: MockIssueTrackerProvider conforme compile et capture les appels
    func testMockConformsAndCapturesCalls() async throws {
        let mock = MockIssueTrackerProvider()

        let issue = try await mock.createIssue(title: "Test", body: "Body")

        XCTAssertTrue(mock.createIssueCalled)
        XCTAssertEqual(issue.url, "https://github.com/org/repo/issues/1")
        XCTAssertEqual(issue.number, 1)

        try await mock.addComment(issueNumber: 1, body: "Comment")
        XCTAssertTrue(mock.addCommentCalled)
    }

    // Cycle 2: IssueTrackerError.unauthorized est catchable en do-catch
    func testUnauthorizedErrorCatched() async {
        let mock = MockIssueTrackerProvider()
        mock.shouldThrow = .unauthorized

        do {
            _ = try await mock.createIssue(title: "Test", body: "Body")
            XCTFail("Expected IssueTrackerError.unauthorized to be thrown")
        } catch let error as IssueTrackerError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testNetworkErrorCatched() async {
        let mock = MockIssueTrackerProvider()
        mock.shouldThrow = .networkError("timeout")

        do {
            _ = try await mock.createIssue(title: "Test", body: "Body")
            XCTFail("Expected IssueTrackerError.networkError to be thrown")
        } catch let error as IssueTrackerError {
            if case .networkError(let message) = error {
                XCTAssertEqual(message, "timeout")
            } else {
                XCTFail("Expected .networkError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testNotConfiguredErrorCatched() async {
        let mock = MockIssueTrackerProvider()
        mock.shouldThrow = .notConfigured

        do {
            try await mock.addComment(issueNumber: 42, body: "Comment")
            XCTFail("Expected IssueTrackerError.notConfigured to be thrown")
        } catch let error as IssueTrackerError {
            XCTAssertEqual(error, .notConfigured)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
