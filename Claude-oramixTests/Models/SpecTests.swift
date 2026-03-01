import XCTest
@testable import Claude_oramix

// MARK: - Test Helpers

private func makeEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
}

private func makeDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}

private func makeSpec(title: String = "Test") -> Spec {
    Spec(title: title)
}

private func makeAcceptanceCriteria(
    given: String = "Given a condition",
    when_: String = "When an action occurs",
    then_: String = "Then an outcome is expected",
    type: CriteriaType = .happyPath
) -> AcceptanceCriteria {
    AcceptanceCriteria(given: given, when_: when_, then_: then_, type: type)
}

// MARK: - Tests

final class SpecTests: XCTestCase {
    func testDecodesLegacyShortcutId() throws {
        let json = """
        {
            "id": "00000001-0000-0000-0000-000000000001",
            "shortcutId": "SC-001",
            "title": "Legacy spec",
            "status": "draft",
            "sections": {
                "what": "",
                "where": [],
                "acceptance": [],
                "nonGoals": [],
                "patterns": []
            },
            "metadata": {
                "labels": [],
                "dependencies": []
            },
            "score": {
                "total": 0,
                "grade": "F",
                "checks": [],
                "suggestions": [],
                "isAgentReady": false
            },
            "createdAt": "2024-01-01T00:00:00Z",
            "updatedAt": "2024-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        let decoded = try makeDecoder().decode(Spec.self, from: json)
        XCTAssertEqual(decoded.issueRef, "SC-001")
    }

    func testDecodesNewIssueRef() throws {
        let json = """
        {
            "id": "00000001-0000-0000-0000-000000000002",
            "issueRef": "https://github.com/x/y/issues/1",
            "title": "New spec",
            "status": "draft",
            "sections": {
                "what": "",
                "where": [],
                "acceptance": [],
                "nonGoals": [],
                "patterns": []
            },
            "metadata": {
                "labels": [],
                "dependencies": []
            },
            "score": {
                "total": 0,
                "grade": "F",
                "checks": [],
                "suggestions": [],
                "isAgentReady": false
            },
            "createdAt": "2024-01-01T00:00:00Z",
            "updatedAt": "2024-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        let decoded = try makeDecoder().decode(Spec.self, from: json)
        XCTAssertEqual(decoded.issueRef, "https://github.com/x/y/issues/1")
    }

    func testSpecCodableRoundTrip() throws {
        let spec = makeSpec()
        let data = try makeEncoder().encode(spec)
        let decoded = try makeDecoder().decode(Spec.self, from: data)
        XCTAssertEqual(decoded.id, spec.id)
        XCTAssertEqual(decoded.title, spec.title)
    }

    func testSpecScoreEmpty() {
        let empty = SpecScore.empty
        XCTAssertEqual(empty.total, 0)
        XCTAssertEqual(empty.grade, .F)
        XCTAssertFalse(empty.isAgentReady)
        XCTAssertTrue(empty.checks.isEmpty)
        XCTAssertTrue(empty.suggestions.isEmpty)
    }

    func testOptionalFieldsNilRoundTrip() throws {
        var spec = makeSpec(title: "Minimal")
        spec.sections.context = nil
        spec.sections.technicalNotes = nil
        spec.execution = nil
        let data = try makeEncoder().encode(spec)
        let decoded = try makeDecoder().decode(Spec.self, from: data)
        XCTAssertNil(decoded.sections.context)
        XCTAssertNil(decoded.sections.technicalNotes)
        XCTAssertNil(decoded.execution)
    }
}
