import Foundation

// MARK: - Spec

struct Spec: Codable, Identifiable {
    let id: UUID
    var shortcutId: String?
    var title: String
    var status: SpecStatus
    var sections: SpecSections
    var metadata: SpecMetadata
    var score: SpecScore
    var execution: ExecutionResult?
    var createdAt: Date
    var updatedAt: Date

    init(title: String) {
        let now = Date()
        self.id = UUID()
        self.shortcutId = nil
        self.title = title
        self.status = .draft
        self.sections = SpecSections()
        self.metadata = SpecMetadata()
        self.score = SpecScore.empty
        self.execution = nil
        self.createdAt = now
        self.updatedAt = now
    }
}

// MARK: - SpecSections

struct SpecSections: Codable {
    var what: String
    var where_: [FileTarget]
    var acceptance: [AcceptanceCriteria]
    var nonGoals: [String]
    var patterns: [PatternRef]
    var context: String?
    var technicalNotes: String?

    init(
        what: String = "",
        where_: [FileTarget] = [],
        acceptance: [AcceptanceCriteria] = [],
        nonGoals: [String] = [],
        patterns: [PatternRef] = [],
        context: String? = nil,
        technicalNotes: String? = nil
    ) {
        self.what = what
        self.where_ = where_
        self.acceptance = acceptance
        self.nonGoals = nonGoals
        self.patterns = patterns
        self.context = context
        self.technicalNotes = technicalNotes
    }

    enum CodingKeys: String, CodingKey {
        case what
        case where_ = "where"
        case acceptance
        case nonGoals
        case patterns
        case context
        case technicalNotes
    }
}

// MARK: - AcceptanceCriteria

struct AcceptanceCriteria: Codable, Identifiable {
    let id: UUID
    var given: String
    var when_: String
    var then_: String
    var type: CriteriaType

    init(
        id: UUID = UUID(),
        given: String = "",
        when_: String = "",
        then_: String = "",
        type: CriteriaType = .happyPath
    ) {
        self.id = id
        self.given = given
        self.when_ = when_
        self.then_ = then_
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case given
        case when_ = "when"
        case then_ = "then"
        case type
    }
}

// MARK: - CriteriaType

enum CriteriaType: String, Codable, CaseIterable {
    case happyPath = "happy_path"
    case errorCase = "error_case"
    case edgeCase = "edge_case"
}

// MARK: - FileTarget

struct FileTarget: Codable, Identifiable {
    let id: UUID
    var path: String
    var description: String

    init(id: UUID = UUID(), path: String = "", description: String = "") {
        self.id = id
        self.path = path
        self.description = description
    }
}

// MARK: - PatternRef

struct PatternRef: Codable, Identifiable {
    let id: UUID
    var name: String
    var reference: String

    init(id: UUID = UUID(), name: String = "", reference: String = "") {
        self.id = id
        self.name = name
        self.reference = reference
    }
}

// MARK: - SpecMetadata

struct SpecMetadata: Codable {
    var estimate: Int?
    var labels: [String]
    var epic: String?
    var dependencies: [String]
    var mergeSafeDeclaration: String?

    init(
        estimate: Int? = nil,
        labels: [String] = [],
        epic: String? = nil,
        dependencies: [String] = [],
        mergeSafeDeclaration: String? = nil
    ) {
        self.estimate = estimate
        self.labels = labels
        self.epic = epic
        self.dependencies = dependencies
        self.mergeSafeDeclaration = mergeSafeDeclaration
    }
}

// MARK: - SpecStatus

enum SpecStatus: String, Codable, CaseIterable {
    case draft
    case ready
    case queued
    case inProgress
    case done
    case failed
    case split
}
