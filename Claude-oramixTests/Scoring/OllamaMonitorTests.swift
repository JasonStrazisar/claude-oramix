import XCTest
@testable import Claude_oramix

// MARK: - OllamaMonitorTests

final class OllamaMonitorTests: XCTestCase {

    // MARK: - Helpers

    private func makeSession(handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data)) -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.requestHandler = handler
        return URLSession(configuration: config)
    }

    // MARK: - Cycle 1: isAvailable() returns false on network error

    func test_isAvailable_returnsFalse_onConnectionRefused() async {
        let session = makeSession { _ in
            throw URLError(.cannotConnectToHost)
        }
        let sut = OllamaScorer(session: session)
        let available = await sut.isAvailable()
        XCTAssertFalse(available)
    }

    // MARK: - Cycle 2: isAvailable() returns true on HTTP 200

    func test_isAvailable_returnsTrue_onHTTP200() async {
        let session = makeSession { _ in
            let response = HTTPURLResponse(
                url: URL(string: "http://localhost:11434/api/tags")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        let sut = OllamaScorer(session: session)
        let available = await sut.isAvailable()
        XCTAssertTrue(available)
    }

    // MARK: - Cycle 3: isAvailable() returns false on non-200 status

    func test_isAvailable_returnsFalse_onHTTP503() async {
        let session = makeSession { _ in
            let response = HTTPURLResponse(
                url: URL(string: "http://localhost:11434/api/tags")!,
                statusCode: 503,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        let sut = OllamaScorer(session: session)
        let available = await sut.isAvailable()
        XCTAssertFalse(available)
    }

    // MARK: - OllamaMonitor: initial status is .checking

    func test_ollamaMonitor_initialStatus_isChecking() async {
        let sut = OllamaMonitor()
        await MainActor.run {
            XCTAssertEqual(sut.status, .checking)
        }
    }

    // MARK: - OllamaMonitor: updateStatus sets .available when isAvailable returns true

    func test_ollamaMonitor_updateStatus_setsAvailable_whenServerResponds200() async {
        let session = makeSession { _ in
            let response = HTTPURLResponse(
                url: URL(string: "http://localhost:11434/api/tags")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        let sut = OllamaMonitor(session: session)
        await sut.updateStatus()
        await MainActor.run {
            XCTAssertEqual(sut.status, .available)
        }
    }

    // MARK: - OllamaMonitor: updateStatus sets .unavailable on network error

    func test_ollamaMonitor_updateStatus_setsUnavailable_onNetworkError() async {
        let session = makeSession { _ in
            throw URLError(.cannotConnectToHost)
        }
        let sut = OllamaMonitor(session: session)
        await sut.updateStatus()
        await MainActor.run {
            XCTAssertEqual(sut.status, .unavailable)
        }
    }
}
