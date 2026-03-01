import XCTest
@testable import Claude_oramix

final class TemporarySpecFileWatcherTests: XCTestCase {

    // MARK: - Cycle 1: filePath format and file creation

    func testFilePathFormat() {
        let sut = TemporarySpecFileWatcher()

        XCTAssertTrue(sut.filePath.hasPrefix("/tmp/specautomatix-"), "filePath should start with /tmp/specautomatix-")
        XCTAssertTrue(FileManager.default.fileExists(atPath: sut.filePath), "temp file should exist at filePath")
    }

    // MARK: - Cycle 2: parses valid JSON written to the file

    func testParsesValidJSON() throws {
        let sut = TemporarySpecFileWatcher()
        let exp = expectation(description: "parsedSections should be set")

        let validJSON = """
        {"what":"test","where":[],"acceptance":[],"nonGoals":[],"patterns":[]}
        """
        let data = validJSON.data(using: .utf8)!
        try data.write(to: URL(fileURLWithPath: sut.filePath))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if sut.parsedSections != nil {
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 2.0)
        XCTAssertNotNil(sut.parsedSections)
        XCTAssertEqual(sut.parsedSections?.what, "test")
    }

    // MARK: - Cycle 3: fallback parseTerminalOutput with ```json block

    func testFallbackParseTerminalOutput() {
        let sut = TemporarySpecFileWatcher()
        let output = """
        Some terminal text before
        ```json
        {"what":"fallback","where":[],"acceptance":[],"nonGoals":[],"patterns":[]}
        ```
        Some terminal text after
        """

        sut.parseTerminalOutput(output)

        XCTAssertNotNil(sut.parsedSections)
        XCTAssertEqual(sut.parsedSections?.what, "fallback")
    }
}
