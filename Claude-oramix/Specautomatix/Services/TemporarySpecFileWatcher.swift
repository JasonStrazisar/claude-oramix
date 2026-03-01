import Foundation
import Combine

// MARK: - TemporarySpecFileWatcher

/// Watches a temporary JSON file at /tmp/specautomatix-{uuid}.json for writes,
/// and publishes parsed SpecSections whenever valid JSON is detected.
/// Also provides a fallback parser for terminal output containing ```json blocks.
final class TemporarySpecFileWatcher: ObservableObject {

    // MARK: - Public

    /// The path to the temporary file being watched.
    let filePath: String

    /// Published parsed sections; set whenever the watched file contains valid SpecSections JSON,
    /// or when parseTerminalOutput(_:) finds a valid ```json block.
    @Published var parsedSections: SpecSections?

    // MARK: - Private

    private var source: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1

    // MARK: - Init

    init() {
        let uuid = UUID().uuidString
        filePath = "/tmp/specautomatix-\(uuid).json"

        // Create the empty temp file
        FileManager.default.createFile(atPath: filePath, contents: nil)

        startWatching()
    }

    // MARK: - Deinit

    deinit {
        source?.cancel()
        if fileDescriptor != -1 {
            close(fileDescriptor)
        }
        // Clean up the temp file
        try? FileManager.default.removeItem(atPath: filePath)
    }

    // MARK: - Public Methods

    /// Parses terminal output looking for a ```json ... ``` block and,
    /// if a valid SpecSections JSON is found inside, updates parsedSections.
    func parseTerminalOutput(_ output: String) {
        guard let sections = extractFromMarkdownBlock(output) else { return }
        if Thread.isMainThread {
            parsedSections = sections
        } else {
            DispatchQueue.main.async {
                self.parsedSections = sections
            }
        }
    }

    // MARK: - Private Methods

    private func startWatching() {
        let fd = open(filePath, O_EVTONLY)
        guard fd != -1 else { return }
        fileDescriptor = fd

        let src = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: .write,
            queue: DispatchQueue.global()
        )

        src.setEventHandler { [weak self] in
            self?.reloadFile()
        }

        src.setCancelHandler { [weak self] in
            guard let self else { return }
            close(self.fileDescriptor)
            self.fileDescriptor = -1
        }

        src.resume()
        source = src
    }

    private func reloadFile() {
        guard let data = FileManager.default.contents(atPath: filePath),
              !data.isEmpty else { return }

        // Attempt direct JSON decode first
        if let sections = try? JSONDecoder().decode(SpecSections.self, from: data) {
            DispatchQueue.main.async {
                self.parsedSections = sections
            }
            return
        }

        // Fallback: treat file contents as text and look for a ```json block
        if let text = String(data: data, encoding: .utf8),
           let sections = extractFromMarkdownBlock(text) {
            DispatchQueue.main.async {
                self.parsedSections = sections
            }
        }
    }

    /// Extracts JSON from a ```json ... ``` markdown block in the given string and
    /// attempts to decode it as SpecSections.
    private func extractFromMarkdownBlock(_ text: String) -> SpecSections? {
        // Find the opening ```json marker
        let openMarker = "```json"
        let closeMarker = "```"

        guard let openRange = text.range(of: openMarker) else { return nil }

        let afterOpen = text[openRange.upperBound...]

        guard let closeRange = afterOpen.range(of: closeMarker) else { return nil }

        let jsonString = String(afterOpen[afterOpen.startIndex..<closeRange.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8) else { return nil }

        return try? JSONDecoder().decode(SpecSections.self, from: jsonData)
    }
}
