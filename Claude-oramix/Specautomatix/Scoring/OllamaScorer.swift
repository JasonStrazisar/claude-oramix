import Foundation

// MARK: - Models

struct OllamaAnalysis: Codable {
    let qualityScore: Double
    let suggestions: [String]
    let splitSuggestions: [SplitSuggestion]
}

struct SplitSuggestion: Codable {
    let title: String
    let rationale: String
}

enum OllamaError: Error, Equatable {
    case serverError(statusCode: Int)
    case invalidResponse
    case decodingError
}

// MARK: - OllamaScorer

struct OllamaScorer {
    private static let endpoint = URL(string: "http://localhost:11434/api/generate")!
    private static let model = "llama3"

    private static let promptTemplate = """
    Analyze the following spec and return a JSON response with:
    - qualityScore: a float between 0.0 and 1.0
    - suggestions: array of strings with improvement suggestions
    - splitSuggestions: array of objects with "title" and "rationale" fields if the spec should be split

    Spec to analyze:
    ___SPEC_PLACEHOLDER___

    Return ONLY valid JSON, no other text.
    """

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func analyzeQuality(spec: Spec) async throws -> OllamaAnalysis {
        let prompt = Self.promptTemplate.replacingOccurrences(
            of: "___SPEC_PLACEHOLDER___",
            with: spec.title
        )

        let body: [String: Any] = [
            "model": Self.model,
            "prompt": prompt,
            "stream": false
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OllamaError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw OllamaError.serverError(statusCode: httpResponse.statusCode)
        }

        struct OllamaRawResponse: Decodable {
            let response: String
        }

        guard let rawResponse = try? JSONDecoder().decode(OllamaRawResponse.self, from: data),
              let innerData = rawResponse.response.data(using: .utf8) else {
            throw OllamaError.decodingError
        }

        guard let analysis = try? JSONDecoder().decode(OllamaAnalysis.self, from: innerData) else {
            throw OllamaError.decodingError
        }

        return analysis
    }
}
