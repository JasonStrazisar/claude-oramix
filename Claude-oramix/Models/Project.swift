import Foundation

// MARK: - IssueTrackerConfig

struct IssueTrackerConfig: Codable, Equatable {
    var type: String
    var baseURL: String
    var projectKey: String

    init(type: String = "", baseURL: String = "", projectKey: String = "") {
        self.type = type
        self.baseURL = baseURL
        self.projectKey = projectKey
    }
}

// MARK: - Project

struct Project: Codable, Identifiable {
    let id: UUID
    var name: String
    var path: String
    var issueTracker: IssueTrackerConfig?

    init(
        id: UUID = UUID(),
        name: String,
        path: String,
        issueTracker: IssueTrackerConfig? = nil
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.issueTracker = issueTracker
    }
}
