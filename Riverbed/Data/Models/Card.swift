import Foundation

class JsonApiData<T: Codable>: Codable {
    var data: T

    init(data: T) {
        self.data = data
    }
}

class JsonApiResourceIdentifier: Codable {
    var type: String
    var id: String

    init(type: String, id: String) {
        self.type = type
        self.id = id
    }
}

class Card: NSObject, Codable {
    let type: String
    var id: String
    var attributes: Card.Attributes

    init(id: String, attributes: Card.Attributes) {
        self.type = "cards"
        self.id = id
        self.attributes = attributes
    }

    class Attributes: Codable {
        var fieldValues: [String: FieldValue?]

        init(fieldValues: [String: FieldValue?]) {
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
        var boardData: JsonApiData<JsonApiResourceIdentifier>?

        init(boardData: JsonApiData<JsonApiResourceIdentifier>) {
            self.boardData = boardData
        }

        enum CodingKeys: String, CodingKey {
            case boardData = "board"
        }
    }

}

extension Card {
    static func group(cards: [Card], for column: Column, with elements: [Element]) -> [CardGroup] {
        // filter
        var filteredCards: [Card]
        if let cardInclusionConditions = column.attributes.cardInclusionConditions {
            filteredCards = cards.filter { (card) in
                checkConditions(fieldValues: card.attributes.fieldValues,
                                conditions: cardInclusionConditions,
                                elements: elements)
            }
        } else {
            filteredCards = cards
        }

        // TODO: are choice labels used for choice fields?

        // sort
        var sortedCards: [Card]
        if let cardSortOrder = column.attributes.cardSortOrder {
            sortedCards = sort(cards: filteredCards, by: cardSortOrder)
        } else {
            sortedCards = filteredCards
        }

        // group
        let cardGrouping = column.attributes.cardGrouping
        return group(cards: sortedCards, by: cardGrouping, elements: elements)
    }

    private static func checkConditions(fieldValues: [String: FieldValue?],
                                        conditions: [Condition]?,
                                        elements: [Element]) -> Bool {
        guard let conditions = conditions else {
            return true
        }

        return conditions.allSatisfy { (condition) in
            guard let field = condition.field,
                  let query = condition.query,
                  field != "" else {
                return true
            }

            let fieldObject = elements.first { $0.id == field }
            guard let dataType = fieldObject?.attributes.dataType else {
                return true
            }
            var value: FieldValue?
            if let tempValue = fieldValues[field] {
                value = tempValue // attempt to handle a double optional
            }
            return query.match(value: value, dataType: dataType, options: condition.options)
        }
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

enum FieldValue: Codable, Equatable {
    case string(String)
    case dictionary([String: String])

    static func == (lhs: FieldValue, rhs: FieldValue) -> Bool {
        switch (lhs, rhs) {
        case (let .string(lhs), let .string(rhs)):
            return lhs == rhs
        case (let .dictionary(lhs), let .dictionary(rhs)):
            return lhs == rhs
        default:
            return false
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
            return
        }
        if let value = try? container.decode([String: String].self) {
            self = .dictionary(value)
            return
        }
        throw DecodingError.typeMismatch(
            FieldValue.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Not a valid kind of FieldValue"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(stringValue):
            try container.encode(stringValue)
        case let .dictionary(dictionaryValue):
            try container.encode(dictionaryValue)
        }
    }
}
