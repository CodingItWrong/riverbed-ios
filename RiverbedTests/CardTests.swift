@testable import Riverbed
import XCTest

final class CardTests: XCTestCase {
    func test_group_whenNoCards_returnsNoGroups() {
        let cards = [Card]()
        let column = Column(
            id: "27",
            attributes: Column.Attributes(name: "DUMMY"))
        let elements = [Element]()
        let result = Card.group(cards: cards, for: column, with: elements)
        XCTAssertEqual(result.count, 0)
    }
}
