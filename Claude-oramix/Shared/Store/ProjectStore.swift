import Foundation

// MARK: - ProjectStore

final class ProjectStore: ObservableObject {

    // MARK: - Published State

    @Published private(set) var projects: [Project] = []
    @Published var activeProjectId: UUID?

    // MARK: - Private Properties

    private let directory: URL

    private var fileURL: URL {
        directory.appendingPathComponent("projects.json")
    }

    private static var defaultDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Claude-oramix")
    }

    private var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.outputFormatting = .prettyPrinted
        return e
    }

    private var decoder: JSONDecoder {
        JSONDecoder()
    }

    // MARK: - Initializers

    init(directory: URL) {
        self.directory = directory
    }

    convenience init() {
        self.init(directory: ProjectStore.defaultDirectory)
    }

    // MARK: - Computed

    var activeProject: Project? {
        guard let id = activeProjectId else { return nil }
        return projects.first { $0.id == id }
    }

    // MARK: - Persistence

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else {
            projects = []
            return
        }
        projects = (try? decoder.decode([Project].self, from: data)) ?? []
    }

    func save() {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try encoder.encode(projects)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Silently fail — caller should not crash on save errors
        }
    }

    // MARK: - CRUD

    func add(_ project: Project) {
        let projectDir = directory.appendingPathComponent("projects").appendingPathComponent(project.id.uuidString)
        try? FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)
        projects.append(project)
        save()
    }

    func update(_ project: Project) {
        projects = projects.map { $0.id == project.id ? project : $0 }
        save()
    }

    func delete(_ projectId: UUID) {
        projects = projects.filter { $0.id != projectId }
        save()
    }
}
