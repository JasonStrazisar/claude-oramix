import Foundation

// MARK: - URLSessionProtocol

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

// MARK: - GitHubIssueResponse

private struct GitHubIssueResponse: Decodable {
    let htmlURL: String
    let number: Int

    enum CodingKeys: String, CodingKey {
        case htmlURL = "html_url"
        case number
    }
}

// MARK: - GitHubIssueTracker

struct GitHubIssueTracker: IssueTrackerProvider {

    private let owner: String
    private let repo: String
    private let keychainService: String
    private let urlSession: URLSessionProtocol

    init(
        owner: String,
        repo: String,
        keychainService: String = "claude-oramix.github-token",
        urlSession: URLSessionProtocol = URLSession.shared
    ) {
        self.owner = owner
        self.repo = repo
        self.keychainService = keychainService
        self.urlSession = urlSession
    }

    // MARK: - IssueTrackerProvider

    func createIssue(title: String, body: String) async throws -> CreatedIssue {
        let token = try retrieveToken()
        let endpoint = "https://api.github.com/repos/\(owner)/\(repo)/issues"
        let requestBody = ["title": title, "body": body]
        let request = try buildRequest(endpoint: endpoint, method: "POST", body: requestBody, token: token)

        let (data, response) = try await performRequest(request)
        let decoded = try decodeResponse(GitHubIssueResponse.self, from: data, response: response)

        return CreatedIssue(url: decoded.htmlURL, number: decoded.number)
    }

    func addComment(issueNumber: Int, body: String) async throws {
        let token = try retrieveToken()
        let endpoint = "https://api.github.com/repos/\(owner)/\(repo)/issues/\(issueNumber)/comments"
        let requestBody = ["body": body]
        let request = try buildRequest(endpoint: endpoint, method: "POST", body: requestBody, token: token)

        let (_, response) = try await performRequest(request)
        guard let http = response as? HTTPURLResponse else {
            throw IssueTrackerError.networkError("Invalid response")
        }
        try mapHTTPError(statusCode: http.statusCode)
    }

    // MARK: - Private Helpers

    private func retrieveToken() throws -> String {
        guard let token = KeychainService.retrieve(for: keychainService) else {
            throw IssueTrackerError.notConfigured
        }
        return token
    }

    private func buildRequest(
        endpoint: String,
        method: String,
        body: [String: String],
        token: String
    ) throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw IssueTrackerError.networkError("Invalid URL: \(endpoint)")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await urlSession.data(for: request)
        } catch let error as IssueTrackerError {
            throw error
        } catch {
            throw IssueTrackerError.networkError(error.localizedDescription)
        }
    }

    private func decodeResponse<T: Decodable>(_ type: T.Type, from data: Data, response: URLResponse) throws -> T {
        guard let http = response as? HTTPURLResponse else {
            throw IssueTrackerError.networkError("Invalid response")
        }
        try mapHTTPError(statusCode: http.statusCode)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw IssueTrackerError.networkError("Decode failed: \(error.localizedDescription)")
        }
    }

    private func mapHTTPError(statusCode: Int) throws {
        switch statusCode {
        case 200...299:
            return
        case 401:
            throw IssueTrackerError.unauthorized
        case 404:
            throw IssueTrackerError.networkError("Not found (404)")
        case 422:
            throw IssueTrackerError.networkError("Unprocessable entity (422)")
        default:
            throw IssueTrackerError.networkError("HTTP error \(statusCode)")
        }
    }
}
