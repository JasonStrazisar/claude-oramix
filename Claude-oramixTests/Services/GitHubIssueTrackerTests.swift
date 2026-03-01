import XCTest
@testable import Claude_oramix

// MARK: - MockURLSession

private final class MockURLSession: URLSessionProtocol {
    var responseData: Data = Data()
    var statusCode: Int = 200
    var dataTaskCallCount: Int = 0
    var errorToThrow: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataTaskCallCount += 1
        if let error = errorToThrow { throw error }
        let url = request.url ?? URL(string: "https://api.github.com")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return (responseData, response)
    }
}

// MARK: - Tests

final class GitHubIssueTrackerTests: XCTestCase {

    private let keychainService = "claude-oramix.github-token.test"

    override func tearDown() {
        super.tearDown()
        KeychainService.delete(for: keychainService)
    }

    // Cycle 1 — Happy path: HTTP 201 → CreatedIssue
    func testCreateIssueSuccess() async throws {
        let session = MockURLSession()
        session.statusCode = 201
        let payload = #"{"html_url":"https://github.com/org/repo/issues/42","number":42}"#
        session.responseData = Data(payload.utf8)

        KeychainService.store(token: "test-token", for: keychainService)

        let tracker = GitHubIssueTracker(
            owner: "org",
            repo: "repo",
            keychainService: keychainService,
            urlSession: session
        )

        let issue = try await tracker.createIssue(title: "Test", body: "body")

        XCTAssertEqual(issue.number, 42)
        XCTAssertEqual(issue.url, "https://github.com/org/repo/issues/42")
    }

    // Cycle 2 — HTTP 401 → IssueTrackerError.unauthorized
    func testCreateIssueUnauthorized() async throws {
        let session = MockURLSession()
        session.statusCode = 401
        session.responseData = Data(#"{"message":"Bad credentials"}"#.utf8)

        KeychainService.store(token: "bad-token", for: keychainService)

        let tracker = GitHubIssueTracker(
            owner: "org",
            repo: "repo",
            keychainService: keychainService,
            urlSession: session
        )

        do {
            _ = try await tracker.createIssue(title: "Test", body: "body")
            XCTFail("Expected IssueTrackerError.unauthorized")
        } catch let error as IssueTrackerError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // Cycle 3 — Token nil → IssueTrackerError.notConfigured (no network call)
    func testCreateIssueNotConfigured() async throws {
        let session = MockURLSession()

        // Do NOT store any token in Keychain
        let tracker = GitHubIssueTracker(
            owner: "org",
            repo: "repo",
            keychainService: keychainService,
            urlSession: session
        )

        do {
            _ = try await tracker.createIssue(title: "Test", body: "body")
            XCTFail("Expected IssueTrackerError.notConfigured")
        } catch let error as IssueTrackerError {
            XCTAssertEqual(error, .notConfigured)
            XCTAssertEqual(session.dataTaskCallCount, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
