import XCTest
@testable import Claude_oramix

final class KeychainServiceTests: XCTestCase {

    private let testService = "claude-oramix.test-keychain"

    override func tearDown() {
        super.tearDown()
        KeychainService.delete(for: testService)
    }

    // Cycle 1: store + retrieve
    func testStoreAndRetrieve() {
        KeychainService.store(token: "test", for: testService)
        XCTAssertEqual(KeychainService.retrieve(for: testService), "test")
    }

    // Cycle 2: delete clears token
    func testDeleteClearsToken() {
        KeychainService.store(token: "secret", for: testService)
        KeychainService.delete(for: testService)
        XCTAssertNil(KeychainService.retrieve(for: testService))
    }

    // Cycle 3: overwrite duplicate
    func testStoreOverwritesDuplicate() {
        KeychainService.store(token: "v1", for: testService)
        KeychainService.store(token: "v2", for: testService)
        XCTAssertEqual(KeychainService.retrieve(for: testService), "v2")
    }
}
