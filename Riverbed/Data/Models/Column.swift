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
        var name: String
        var displayOrder: Int?
        var cardInclusionConditions: [CardInclusionCondition]?
        var sortOrder: SortOrder?

        enum CodingKeys: String, CodingKey {
            case name
            case displayOrder = "display_order"
            case cardInclusionConditions = "card-inclusion-conditions"
        }
    }

    class CardInclusionCondition: Codable {
        var field: String
        var query: String
    }

    class SortOrder: Codable {
        var field: String
        var direction: Direction
    }

    enum Direction: String, Codable {
        case ascending = "ASCENDING"
        case descending = "DESCENDING"
    }
}
