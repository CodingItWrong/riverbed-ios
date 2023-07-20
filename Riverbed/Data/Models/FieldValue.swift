import Foundation

enum FieldValue: Codable, Equatable, Hashable {
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
