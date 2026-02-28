import XCTest
@testable import Claude_oramix


final class ContentViewTests: XCTestCase {
    func testDefaultTabIsSpecautomatix() {
        let view = ContentView()
        XCTAssertEqual(view.selectedTab, 0)
    }
}
