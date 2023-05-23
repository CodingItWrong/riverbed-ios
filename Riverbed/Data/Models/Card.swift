import Foundation

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

        enum CodingKeys: String, CodingKey {
            case fieldValues = "field-values"
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
}
