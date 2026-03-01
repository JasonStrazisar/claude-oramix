import XCTest
@testable import Claude_oramix


final class ContentViewTests: XCTestCase {
    func testDefaultAgentIsSpecautomatix() {
        XCTAssertEqual(Agent.specautomatix.rawValue, 0)
        XCTAssertEqual(Agent.allCases.first, .specautomatix)
    }
}
