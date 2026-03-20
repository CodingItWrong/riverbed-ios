@testable import Riverbed
import XCTest

final class ColumnStoreTests: XCTestCase {

    func test_columnCardsURL_constructsCorrectURL() {
        let url = RiverbedAPI.columnCardsURL(for: "42")
        XCTAssertTrue(url.absoluteString.hasSuffix("/columns/42/cards"),
                      "Expected URL to end in /columns/42/cards, got \(url.absoluteString)")
    }

}
