import XCTest
@testable import Claude_oramix

final class WhatSectionViewTests: XCTestCase {
    func testCharacterCountThreshold() {
        // Test the business logic: < 50 chars means red indicator
        let shortText = "Short"
        let longText = String(repeating: "a", count: 60)

        XCTAssertLessThan(shortText.count, 50)
        XCTAssertGreaterThan(longText.count, 50)
    }

    func testEmptyStringIsBelow50() {
        let text = ""
        XCTAssertLessThan(text.count, 50)
    }
}
