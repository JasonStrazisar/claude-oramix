import Foundation

// MARK: - Spec

struct Spec: Codable, Identifiable {
    let id: UUID
    var issueRef: String?
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
        self.issueRef = nil
        self.title = title
        self.status = .draft
        self.sections = SpecSections()
        self.metadata = SpecMetadata()
        self.score = SpecScore.empty
        self.execution = nil
        self.createdAt = now
        self.updatedAt = now
    }

    // MARK: - CodingKeys (with legacy shortcutId fallback)

    enum CodingKeys: String, CodingKey {
        case id
        case issueRef
        case shortcutId  // legacy key — read-only fallback
        case title
        case status
        case sections
        case metadata
        case score
        case execution
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        // issueRef: prefer "issueRef" key, fall back to legacy "shortcutId"
        issueRef = try container.decodeIfPresent(String.self, forKey: .issueRef)
            ?? container.decodeIfPresent(String.self, forKey: .shortcutId)
        title = try container.decode(String.self, forKey: .title)
        status = try container.decode(SpecStatus.self, forKey: .status)
        sections = try container.decode(SpecSections.self, forKey: .sections)
        metadata = try container.decode(SpecMetadata.self, forKey: .metadata)
        score = try container.decode(SpecScore.self, forKey: .score)
        execution = try container.decodeIfPresent(ExecutionResult.self, forKey: .execution)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(issueRef, forKey: .issueRef)
        try container.encode(title, forKey: .title)
        try container.encode(status, forKey: .status)
        try container.encode(sections, forKey: .sections)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(score, forKey: .score)
        try container.encodeIfPresent(execution, forKey: .execution)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
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
