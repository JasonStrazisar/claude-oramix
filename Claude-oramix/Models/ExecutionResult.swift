import Foundation

// MARK: - ExecutionResult

struct ExecutionResult: Codable {
    var branch: String
    var prURL: String?
    var model: String
    var tokensUsed: Int?
    var duration: TimeInterval
    var status: ExecutionStatus
    var logs: String
    var startedAt: Date
    var completedAt: Date

    init(
        branch: String = "",
        prURL: String? = nil,
        model: String = "",
        tokensUsed: Int? = nil,
        duration: TimeInterval = 0,
        status: ExecutionStatus = .success,
        logs: String = "",
        startedAt: Date = Date(),
        completedAt: Date = Date()
    ) {
        self.branch = branch
        self.prURL = prURL
        self.model = model
        self.tokensUsed = tokensUsed
        self.duration = duration
        self.status = status
        self.logs = logs
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}

// MARK: - ExecutionStatus

enum ExecutionStatus: String, Codable {
    case success
    case testsFailed
    case error
    case timeout
}
