import Foundation

// MARK: - SpecScore

struct SpecScore: Codable {
    var total: Int
    var grade: ScoreGrade
    var checks: [ScoreCheck]
    var suggestions: [String]
    var isAgentReady: Bool

    init(
        total: Int = 0,
        grade: ScoreGrade = .F,
        checks: [ScoreCheck] = [],
        suggestions: [String] = [],
        isAgentReady: Bool = false
    ) {
        self.total = total
        self.grade = grade
        self.checks = checks
        self.suggestions = suggestions
        self.isAgentReady = isAgentReady
    }

    static var empty: SpecScore {
        SpecScore(
            total: 0,
            grade: .F,
            checks: [],
            suggestions: [],
            isAgentReady: false
        )
    }
}

// MARK: - ScoreGrade

enum ScoreGrade: String, Codable {
    case A, B, C, D, F
}

// MARK: - ScoreCheck

struct ScoreCheck: Codable, Identifiable {
    let id: UUID
    var category: CheckCategory
    var name: String
    var passed: Bool
    var weight: Int
    var message: String

    init(
        id: UUID = UUID(),
        category: CheckCategory = .completeness,
        name: String = "",
        passed: Bool = false,
        weight: Int = 1,
        message: String = ""
    ) {
        self.id = id
        self.category = category
        self.name = name
        self.passed = passed
        self.weight = weight
        self.message = message
    }
}

// MARK: - CheckCategory

enum CheckCategory: String, Codable, CaseIterable {
    case completeness
    case clarity
    case testability
    case scope
    case safety
}
