import Foundation

// MARK: - OllamaStatus

enum OllamaStatus: Equatable {
    case available
    case unavailable
    case checking
}

// MARK: - OllamaMonitor

final class OllamaMonitor: ObservableObject {
    @Published private(set) var status: OllamaStatus = .checking

    private let scorer: OllamaScorer
    private var monitoringTask: Task<Void, Never>?

    init(session: URLSession = .shared) {
        self.scorer = OllamaScorer(session: session)
    }

    @MainActor
    func updateStatus() async {
        let available = await scorer.isAvailable()
        status = available ? .available : .unavailable
    }

    @MainActor
    func startMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = Task { @MainActor in
            while !Task.isCancelled {
                await updateStatus()
                try? await Task.sleep(nanoseconds: 30_000_000_000)
            }
        }
    }

    @MainActor
    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
    }
}
