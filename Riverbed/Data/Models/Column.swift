import Foundation

class Column: Codable {
    let type: String
    var id: String
    var attributes: Column.Attributes

    init(id: String, attributes: Column.Attributes) {
        self.type = "columns"
        self.id = id
        self.attributes = attributes
    }

    class Attributes: Codable {
        var name: String?
        var cardInclusionConditions: [Condition]?
        var cardGrouping: SortOrder?
        var cardSortOrder: SortOrder?
        var displayOrder: Int?

        enum CodingKeys: String, CodingKey {
            case name
            case cardInclusionConditions = "card-inclusion-conditions"
            case cardGrouping = "card-grouping"
            case cardSortOrder = "card-sort-order"
            case displayOrder = "display-order"
        }

        init(name: String? = nil,
             cardInclusionConditions: [Condition]? = nil,
             cardGrouping: SortOrder? = nil,
             cardSortOrder: SortOrder? = nil,
             displayOrder: Int? = nil) {
            self.name = name
            self.cardInclusionConditions = cardInclusionConditions
            self.cardGrouping = cardGrouping
            self.cardSortOrder = cardSortOrder
            self.displayOrder = displayOrder
        }
    }

    class SortOrder: Codable {
        var field: String?
        var direction: Direction?
    }

    enum Direction: String, Codable {
        case ascending = "ASCENDING"
        case descending = "DESCENDING"
    }
}

class NewColumn: Codable {
    let type: String
    var attributes: Column.Attributes
    var relationships: NewColumn.Relationships?

    init(attributes: Column.Attributes, relationships: NewColumn.Relationships? = nil) {
        self.type = "columns"
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
