import XCTest
@testable import Claude_oramix

// MARK: - MockURLProtocol

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - OllaScorerTests

final class OllaScorerTests: XCTestCase {

    // MARK: - Cycle 1: OllamaAnalysis decodes from JSON

    func test_ollamaAnalysis_decodesFromJSON() throws {
        let json = """
        {"qualityScore": 0.8, "suggestions": ["improve context"], "splitSuggestions": []}
        """.data(using: .utf8)!
        XCTAssertNoThrow(try JSONDecoder().decode(OllamaAnalysis.self, from: json))
    }

    // MARK: - Cycle 2: analyzeQuality POST + parse response

    func test_analyzeQuality_parsesValidResponse() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let sut = OllamaScorer(session: session)

        let innerJSON = #"{"qualityScore": 0.8, "suggestions": ["improve"], "splitSuggestions": []}"#
        let escapedInner = innerJSON.replacingOccurrences(of: "\"", with: "\\\"")
        let ollamaResponse = "{\"model\":\"llama3\",\"response\":\"\(escapedInner)\",\"done\":true}"

        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "http://localhost:11434/api/generate")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, ollamaResponse.data(using: .utf8)!)
        }

        let spec = Spec(title: "Test")
        let analysis = try await sut.analyzeQuality(spec: spec)
        XCTAssertEqual(analysis.qualityScore, 0.8)
    }

    // MARK: - Cycle 3: HTTP 500 → throws OllamaError.serverError

    func test_analyzeQuality_throwsOnHTTP500() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let sut = OllamaScorer(session: session)

        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "http://localhost:11434/api/generate")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let spec = Spec(title: "Test")
        do {
            _ = try await sut.analyzeQuality(spec: spec)
            XCTFail("Should have thrown")
        } catch OllamaError.serverError(let code) {
            XCTAssertEqual(code, 500)
        }
    }
}
