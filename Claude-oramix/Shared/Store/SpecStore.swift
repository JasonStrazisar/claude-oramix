import Foundation

// MARK: - SpecStore

final class SpecStore: ObservableObject {

    // MARK: - Published State

    @Published private(set) var specs: [Spec] = []

    // MARK: - Private Properties

    private let directory: URL

    private var fileURL: URL {
        directory.appendingPathComponent("specs.json")
    }

    private static var defaultDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Claude-oramix")
    }

    private var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.outputFormatting = .prettyPrinted
        e.dateEncodingStrategy = .iso8601
        return e
    }

    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    // MARK: - Initializers

    init(directory: URL) {
        self.directory = directory
    }

    convenience init() {
        self.init(directory: SpecStore.defaultDirectory)
    }

    // MARK: - CRUD

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else {
            specs = []
            return
        }
        specs = (try? decoder.decode([Spec].self, from: data)) ?? []
    }

    func save() {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try encoder.encode(specs)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Silently fail — caller should not crash on save errors
        }
    }

    func add(_ spec: Spec) {
        specs.append(spec)
        save()
    }

    func update(_ spec: Spec) {
        specs = specs.map { $0.id == spec.id ? spec : $0 }
        save()
    }

    func delete(_ specId: UUID) {
        specs = specs.filter { $0.id != specId }
        save()
    }

    // MARK: - Split

    @discardableResult
    func createSubSpecs(from proposals: [SplitProposal], parent: Spec) -> [Spec] {
        let subSpecs: [Spec] = proposals.map { proposal in
            let resolvedTitle = proposal.title.isEmpty ? "Sub-spec" : proposal.title
            var subSpec = Spec(title: resolvedTitle)
            subSpec.sections.what = proposal.what
            subSpec.metadata.estimate = proposal.estimate
            return subSpec
        }
        subSpecs.forEach { add($0) }

        var updatedParent = parent
        updatedParent.status = .split
        update(updatedParent)

        return subSpecs
    }
}
