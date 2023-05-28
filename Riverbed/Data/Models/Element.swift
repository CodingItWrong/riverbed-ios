import Foundation

class Element: Codable, Equatable {
    enum ElementType: String, Codable {
        case field = "field"
        case button = "button"
        case buttonMenu = "button_menu"
    }

    enum DataType: String, Codable {
        case text = "text"
        case date = "date"
        case number = "number"
        case dateTime = "datetime"
        case choice = "choice"
        case geolocation = "geolocation"
    }

    let type: String
    var id: String
    var attributes: Element.Attributes

    init(id: String, attributes: Element.Attributes) {
        self.type = "elements"
        self.id = id
        self.attributes = attributes
    }

    static func == (lhs: Element, rhs: Element) -> Bool {
        lhs.id == rhs.id
    }

    static func areInIncreasingOrder(lhs: Element, rhs: Element) -> Bool {
        // these two defaults seem to keep elements in the order returned when all are missing a display order
        guard let lhsOrder = lhs.attributes.displayOrder else { return false }
        guard let rhsOrder = rhs.attributes.displayOrder else { return true }

        return lhsOrder < rhsOrder
    }

    func formatString(from value: FieldValue) -> String? {
        guard let dataType = attributes.dataType else {
            return nil
        }

        switch value {
        case let .string(stringValue):
            switch dataType {
            case .text:
                return stringValue
            case .number:
                return stringValue
            case .date:
                return DateUtils.humanString(fromServerString: stringValue) ?? ""
            case .dateTime:
                return DateTimeUtils.humanString(fromServerString: stringValue) ?? ""
            case .choice:
                return attributes.options?.choices?.first { (choice) in
                    choice.id == stringValue
                }?.label
            case .geolocation:
                return nil
            }
        case let .dictionary(dictValue):
            switch dataType {
            case .geolocation:
                if let lat = dictValue["lat"],
                   let lng = dictValue["lng"] {
                    return "(\(lat), \(lng))"
                }
                return nil
            default:
                return nil
            }
        }
    }

    func sortValue(from value: FieldValue?) -> (any Comparable)? {
        guard let dataType = attributes.dataType else {
            return nil
        }

        switch value {
        case .none:
            return nil
        case let .string(stringValue):
            switch dataType {
            case .text, .number, .date, .dateTime:
                return stringValue
            case .choice:
                let index: Int? = attributes.options?.choices?.firstIndex(where: { (choice) in
                    choice.id == stringValue
                })
                return index
            case .geolocation:
                return nil
            }
        case let .dictionary(dictValue):
            switch dataType {
            case .geolocation:
                if let lat = dictValue["lat"] {
                    return lat // arbitrarily chose to sort by latitude
                }
                return nil
            default:
                return nil
            }
        }
    }

    class Attributes: Codable {
        var name: String?
        var elementType: Element.ElementType
        var dataType: Element.DataType?
        var showInSummary: Bool
        var options: Element.Options?
        var displayOrder: Int?
        var showConditions: [Condition]?
        var readOnly: Bool

        enum CodingKeys: String, CodingKey {
            case name
            case elementType = "element-type"
            case dataType = "data-type"
            case showInSummary = "show-in-summary"
            case options
            case displayOrder = "display-order"
            case showConditions = "show-conditions"
            case readOnly = "read-only"
        }
    }

    class Options: Codable {
        var multiline: Bool?
        var showLabelWhenReadOnly: Bool?
        var choices: [Element.Choice]?
        var items: [Element.Item]?

        enum CodingKeys: String, CodingKey {
            case multiline
            case showLabelWhenReadOnly = "show-label-when-read-only"
            case choices
            case items
        }
    }

    class Choice: Codable, Equatable {
        var id: String
        var label: String

        static func == (lhs: Element.Choice, rhs: Element.Choice) -> Bool {
            lhs.id == rhs.id
        }
    }

    class Item: Codable {
        var name: String
        // TODO: actions
    }
}
