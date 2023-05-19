import Foundation

class Card: Codable {
    let type: String
    var id: String
    var attributes: Card.Attributes

    init(id: String, attributes: Card.Attributes) {
        self.type = "cards"
        self.id = id
        self.attributes = attributes
    }

    class Attributes: Codable {
        var fieldValues: [String: FieldValue]

        enum CodingKeys: String, CodingKey {
            case fieldValues = "field-values"
        }
    }

}

enum FieldValue: Codable {
    case string(String)
    case dictionary([String: String])

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
}
