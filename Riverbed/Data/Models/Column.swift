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

    class Attributes: Codable, Equatable {
        var name: String?
        var cardInclusionConditions: [Condition]?
        var cardGrouping: SortOrder?
        var cardSortOrder: SortOrder?
        var displayOrder: Int?
        var summary: Summary?

        static func copy(from old: Attributes) -> Attributes {
            Attributes(name: old.name,
                       cardInclusionConditions: old.cardInclusionConditions?.map { Condition.copy(from: $0) },
                       cardGrouping: SortOrder.copy(from: old.cardGrouping),
                       cardSortOrder: SortOrder.copy(from: old.cardSortOrder),
                       displayOrder: old.displayOrder,
                       summary: Summary.copy(from: old.summary))
        }

        static func == (lhs: Column.Attributes, rhs: Column.Attributes) -> Bool {
            lhs.name == rhs.name &&
            lhs.cardInclusionConditions == rhs.cardInclusionConditions && // TODO: need to manually copy the contents?
            lhs.cardGrouping == rhs.cardGrouping &&
            lhs.cardSortOrder == rhs.cardSortOrder &&
            lhs.displayOrder == rhs.displayOrder &&
            lhs.summary == rhs.summary
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
            self.summary = summary
        }

        enum CodingKeys: String, CodingKey {
            case name
            case cardInclusionConditions = "card-inclusion-conditions"
            case cardGrouping = "card-grouping"
            case cardSortOrder = "card-sort-order"
            case displayOrder = "display-order"
            case summary
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

    class SortOrder: Codable, Equatable {
        var field: String?
        var direction: Direction?

        static func copy(from old: SortOrder?) -> SortOrder? {
            guard let old = old else { return nil }
            return SortOrder(field: old.field, direction: old.direction)
        }

        static func == (lhs: Column.SortOrder, rhs: Column.SortOrder) -> Bool {
            lhs.field == rhs.field &&
            lhs.direction == rhs.direction
        }

        init(field: String? = nil,
             direction: Direction? = nil) {
            self.field = field
            self.direction = direction
        }
    }

    class Summary: Codable, Equatable {
        var function: SummaryFunction?
        var field: String?

        static func copy(from old: Summary?) -> Summary? {
            guard let old = old else { return nil }
            return Summary(function: old.function, field: old.field)
        }

        static func == (lhs: Column.Summary, rhs: Column.Summary) -> Bool {
            lhs.function == rhs.function &&
            lhs.field == rhs.field
        }

        init(function: SummaryFunction? = nil, field: String? = nil) {
            self.function = function
            self.field = field
        }
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
