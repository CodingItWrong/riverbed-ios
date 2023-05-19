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

        enum CodingKeys: String, CodingKey {
            case name
            case displayOrder = "display_order"
        }
    }
}
