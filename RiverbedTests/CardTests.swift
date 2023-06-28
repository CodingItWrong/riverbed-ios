@testable import Riverbed
import XCTest

final class CardTests: XCTestCase {

    // MARK: - group(cards:for:with:)

    func test_group_whenNoCards_returnsNoGroups() {
        let cards = [Card]()
        let column = Column(
            id: "27",
            attributes: Column.Attributes(name: "DUMMY"))
        let elements = [Element]()
        let result = Card.group(cards: cards, for: column, with: elements)
        XCTAssertEqual(result.count, 0)
    }

    func test_group_whenNoSortOrGroup_returnsCardsInOneGroupWithNilValue() {
        let cards = [Card(id: "A"), Card(id: "B")]
        let column = Column(
            id: "27",
            attributes: Column.Attributes(name: "DUMMY",
                                          cardGrouping: nil,
                                          cardSortOrder: nil))
        let elements = [Element]()
        let result = Card.group(cards: cards, for: column, with: elements)
        XCTAssertEqual(result, [CardGroup(value: nil, cards: cards)])
    }

    func test_group_whenSortButNoGroup_returnsSortedCardsInOneGroup() {
        let elements = [
            Element(id: "text",
                    attributes: Element.Attributes(elementType: .field,
                                                   dataType: .text))
        ]
        let cardA = Card(id: "A",
                         attributes: Card.Attributes(
                            fieldValues: ["text": .string("A")]))
        let cardB = Card(id: "B",
                         attributes: Card.Attributes(
                            fieldValues: ["text": .string("B")]))
        let cards = [cardB, cardA]
        let expectedCards = [cardA, cardB]
        let column = Column(
            id: "27",
            attributes: Column.Attributes(name: "DUMMY",
                                          cardGrouping: nil,
                                          cardSortOrder: Column.SortOrder(field: "text",
                                                                          direction: .ascending)))
        let result = Card.group(cards: cards, for: column, with: elements)
        XCTAssertEqual(result, [CardGroup(value: nil, cards: expectedCards)])
    }

    func test_group_whenSortDescending_returnsSortedCardsInOneGroup() {
        let elements = [
            Element(id: "text",
                    attributes: Element.Attributes(elementType: .field,
                                                   dataType: .text))
        ]
        let cardA = Card(id: "A",
                         attributes: Card.Attributes(
                            fieldValues: ["text": .string("A")]))
        let cardB = Card(id: "B",
                         attributes: Card.Attributes(
                            fieldValues: ["text": .string("B")]))
        let cards = [cardA, cardB]
        let expectedCards = [cardB, cardA]
        let column = Column(
            id: "27",
            attributes: Column.Attributes(name: "DUMMY",
                                          cardGrouping: nil,
                                          cardSortOrder: Column.SortOrder(field: "text",
                                                                          direction: .descending)))
        let result = Card.group(cards: cards, for: column, with: elements)
        XCTAssertEqual(result, [CardGroup(value: nil, cards: expectedCards)])
    }

    func test_group_whenGroupButNoSort_returnsCardsGroupedByConfiguredField() {
        let elements = [
            Element(id: "text",
                    attributes: Element.Attributes(elementType: .field,
                                                   dataType: .text))
        ]
        let cardA1 = Card(id: "A1",
                         attributes: Card.Attributes(
                            fieldValues: ["text": .string("A")]))
        let cardA2 = Card(id: "A2",
                         attributes: Card.Attributes(
                            fieldValues: ["text": .string("A")]))
        let cardB = Card(id: "B",
                         attributes: Card.Attributes(
                            fieldValues: ["text": .string("B")]))
        let cards = [cardA1, cardB, cardA2]
        let expectedGroups = [CardGroup(value: .string("A"),
                                        cards: [cardA1, cardA2]),
                              CardGroup(value: .string("B"),
                                        cards: [cardB])]
        let column = Column(
            id: "27",
            attributes: Column.Attributes(name: "DUMMY",
                                          cardGrouping: Column.SortOrder(field: "text",
                                                                         direction: .ascending),
                                          cardSortOrder: nil))

        let result = Card.group(cards: cards, for: column, with: elements)
        XCTAssertEqual(result, expectedGroups)
    }

    func test_group_whenGroupDescending_returnsGroupsInReverseOrder() {
        let elements = [
            Element(id: "text",
                    attributes: Element.Attributes(elementType: .field,
                                                   dataType: .text))
        ]
        let cardA1 = Card(id: "A1",
                         attributes: Card.Attributes(
                            fieldValues: ["text": .string("A")]))
        let cardA2 = Card(id: "A2",
                         attributes: Card.Attributes(
                            fieldValues: ["text": .string("A")]))
        let cardB = Card(id: "B",
                         attributes: Card.Attributes(
                            fieldValues: ["text": .string("B")]))
        let cards = [cardA1, cardB, cardA2]
        let expectedGroups = [CardGroup(value: .string("B"),
                                        cards: [cardB]),
                              CardGroup(value: .string("A"),
                                        cards: [cardA1, cardA2])]
        let column = Column(
            id: "27",
            attributes: Column.Attributes(name: "DUMMY",
                                          cardGrouping: Column.SortOrder(field: "text",
                                                                         direction: .descending),
                                          cardSortOrder: nil))

        let result = Card.group(cards: cards, for: column, with: elements)
        XCTAssertEqual(result, expectedGroups)
    }

    func test_group_whenGroupAndNoSort_returnsCardsSortedWithinGroups() {
        let elements = [
            Element(id: "text1",
                    attributes: Element.Attributes(elementType: .field,
                                                   dataType: .text)),
            Element(id: "text2",
                    attributes: Element.Attributes(elementType: .field,
                                                   dataType: .text))
        ]
        let cardA1 = Card(id: "A1",
                         attributes: Card.Attributes(
                            fieldValues: ["text1": .string("A"),
                                          "text2": .string("A1")]))
        let cardA2 = Card(id: "A2",
                         attributes: Card.Attributes(
                            fieldValues: ["text1": .string("A"),
                                          "text2": .string("A2")]))
        let cardB = Card(id: "B",
                         attributes: Card.Attributes(
                            fieldValues: ["text1": .string("B"),
                                          "text2": .string("B")]))
        let cards = [cardB, cardA2, cardA1]
        let expectedGroups = [CardGroup(value: .string("A"),
                                        cards: [cardA1, cardA2]),
                              CardGroup(value: .string("B"),
                                        cards: [cardB])]
        let column = Column(
            id: "27",
            attributes: Column.Attributes(name: "DUMMY",
                                          cardGrouping: Column.SortOrder(field: "text1",
                                                                         direction: .ascending),
                                          cardSortOrder: Column.SortOrder(field: "text2",
                                                                          direction: .ascending)))

        let result = Card.group(cards: cards, for: column, with: elements)
        XCTAssertEqual(result, expectedGroups)
    }
}
