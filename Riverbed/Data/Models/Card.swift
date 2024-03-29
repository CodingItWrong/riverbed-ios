import Foundation

class Card: NSObject, Codable {
    let type: String
    var id: String
    var attributes: Card.Attributes

    init(id: String, attributes: Card.Attributes = Card.Attributes()) {
        self.type = "cards"
        self.id = id
        self.attributes = attributes
    }

    class Attributes: Codable {
        var fieldValues: [String: FieldValue?]

        init(fieldValues: [String: FieldValue?] = [:]) {
            self.fieldValues = fieldValues
        }

        enum CodingKeys: String, CodingKey {
            case fieldValues = "field-values"
        }
    }
}

class NewCard: NSObject, Codable {
    let type: String
    var attributes: Card.Attributes
    var relationships: NewCard.Relationships?

    init(attributes: Card.Attributes, relationships: NewCard.Relationships? = nil) {
        self.type = "cards"
        self.attributes = attributes
        self.relationships = relationships
    }

    class Relationships: Codable {
        var boardData: JSONAPI.Data<JSONAPI.ResourceIdentifier>?

        init(boardData: JSONAPI.Data<JSONAPI.ResourceIdentifier>) {
            self.boardData = boardData
        }

        enum CodingKeys: String, CodingKey {
            case boardData = "board"
        }
    }

}

// when this was a struct, incrementally creating them didn't seem to work
class CardGroup: Equatable {
    var value: FieldValue?
    var cards: [Card]

    init(value: FieldValue? = nil, cards: [Card]) {
        self.value = value
        self.cards = cards
    }

    static func == (lhs: CardGroup, rhs: CardGroup) -> Bool {
        lhs.value == rhs.value && lhs.cards == rhs.cards
    }
}

extension Card {
    static func filter(cards: [Card], for column: Column, with elements: [Element]) -> [Card] {
        guard let cardInclusionConditions = column.attributes.cardInclusionConditions else { return cards }

        return cards.filter { (card) in
            checkConditions(fieldValues: card.attributes.fieldValues,
                            conditions: cardInclusionConditions,
                            elements: elements)
        }
    }

    static func group(cards: [Card], for column: Column, with elements: [Element]) -> [CardGroup] {
        // TODO: are choice labels used for choice fields?

        // sort
        var sortedCards: [Card]
        if let cardSortOrder = column.attributes.cardSortOrder {
            sortedCards = sort(cards: cards, by: cardSortOrder)
        } else {
            sortedCards = cards
        }

        // group
        let cardGrouping = column.attributes.cardGrouping
        return group(cards: sortedCards, by: cardGrouping, elements: elements)
    }

    private static func sort(cards: [Card],
                             by sortOrder: Column.SortOrder) -> [Card] {
        guard let field = sortOrder.field,
              let direction = sortOrder.direction else {
            return cards
        }

        let sortedCards = cards.sorted { (cardA, cardB) in
            guard let aValue = cardA.attributes.fieldValues[field],
                  case let .string(aValue) = aValue else { return true }
            guard let bValue = cardB.attributes.fieldValues[field],
                  case let .string(bValue) = bValue else { return false }
            return aValue < bValue
        }
        switch direction {
        case .ascending: return sortedCards
        case .descending: return sortedCards.reversed()
        }
    }

    private static func group(cards: [Card],
                              by cardGrouping: Column.SortOrder?,
                              elements: [Element]) -> [CardGroup] {
        guard let cardGrouping = cardGrouping,
              let field = cardGrouping.field,
              let direction = cardGrouping.direction,
              let groupField = elements.first(where: { $0.id == field }) else {
            if cards.isEmpty {
                return []
            } else {
                return [CardGroup(value: nil, cards: cards)]
            }
        }

        var cardGroups = [CardGroup]()

        cards.forEach { (card) in
            let groupValue: FieldValue? = {
                if let groupValue = card.attributes.fieldValues[field] {
                    return groupValue
                } else {
                    return nil
                }
            }()

            if let existingGroup = cardGroups.first(where: { $0.value == groupValue }) {
                existingGroup.cards.append(card)
            } else {
                let newGroup = CardGroup(value: groupValue, cards: [card])
                cardGroups.append(newGroup)
            }
        }

        let sortedCardGroups = cardGroups.sorted { (lhs, rhs) in
            guard let aValue = groupField.sortValue(from: lhs.value) else { return true }
            guard let bValue = groupField.sortValue(from: rhs.value) else { return false }

            if let aString = aValue as? String, let bString = bValue as? String {
                return aString < bString
            }
            if let aInt = aValue as? Int, let bInt = bValue as? Int {
                return aInt < bInt
            }

            preconditionFailure("Unexpected types of sort values")
        }

        switch direction {
        case .ascending: return sortedCardGroups
        case .descending: return sortedCardGroups.reversed()
        }
    }
}
