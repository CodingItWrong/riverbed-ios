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
        var summary: Summary?

        enum CodingKeys: String, CodingKey {
            case name
            case cardInclusionConditions = "card-inclusion-conditions"
            case cardGrouping = "card-grouping"
            case cardSortOrder = "card-sort-order"
            case displayOrder = "display-order"
            case summary
        }

        init(name: String? = nil,
             cardInclusionConditions: [Condition]? = nil,
             cardGrouping: SortOrder? = nil,
             cardSortOrder: SortOrder? = nil,
             displayOrder: Int? = nil,
             summary: Summary? = nil) {
            self.name = name
            self.cardInclusionConditions = cardInclusionConditions
            self.cardGrouping = cardGrouping
            self.cardSortOrder = cardSortOrder
            self.displayOrder = displayOrder
        }

        init(shallowCloning original: Column.Attributes) {
            self.name = original.name
            self.cardInclusionConditions = original.cardInclusionConditions
            self.cardGrouping = original.cardGrouping
            self.cardSortOrder = original.cardSortOrder
            self.displayOrder = original.displayOrder
        }
    }

    enum Direction: String, Codable {
        case ascending = "ASCENDING"
        case descending = "DESCENDING"

        var label: String {
            switch self {
            case .ascending: return "Ascending"
            case .descending: return "Descending"
            }
        }
    }

    class SortOrder: Codable {
        var field: String?
        var direction: Direction?

        init(field: String? = nil,
             direction: Direction? = nil) {
            self.field = field
            self.direction = direction
        }
    }

    class Summary: Codable {
        var function: SummaryFunction?
        var field: String?
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
        var boardData: JSONAPI.Data<JSONAPI.ResourceIdentifier>?

        init(boardData: JSONAPI.Data<JSONAPI.ResourceIdentifier>) {
            self.boardData = boardData
        }

        enum CodingKeys: String, CodingKey {
            case boardData = "board"
        }
    }
}
