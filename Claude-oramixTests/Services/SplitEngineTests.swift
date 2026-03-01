import XCTest
@testable import Claude_oramix

final class SplitEngineTests: XCTestCase {

    // MARK: - Cycle 1: estimate > 3 triggers split proposals

    func test_propose_withHighEstimate_returnsNonEmptyProposals() {
        var spec = Spec(title: "High estimate spec")
        spec.metadata = SpecMetadata(estimate: 4)
        let sut = SplitEngine()

        let result = sut.propose(spec: spec, ollamaAnalysis: nil)

        XCTAssertFalse(result.isEmpty)
    }

    // MARK: - Cycle 2: OllamaAnalysis splitSuggestions are included

    func test_propose_withLowEstimateAndOllamaSuggestions_returnsSuggestions() {
        var spec = Spec(title: "Low estimate spec")
        spec.metadata = SpecMetadata(estimate: 2)
        let analysis = OllamaAnalysis(
            qualityScore: 0.8,
            suggestions: [],
            splitSuggestions: [
                SplitSuggestion(title: "Part A", rationale: "First slice"),
                SplitSuggestion(title: "Part B", rationale: "Second slice")
            ]
        )
        let sut = SplitEngine()

        let result = sut.propose(spec: spec, ollamaAnalysis: analysis)

        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains { $0.title == "Part A" })
        XCTAssertTrue(result.contains { $0.title == "Part B" })
    }
}
