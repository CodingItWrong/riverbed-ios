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
        var actions: [Element.Action]?
        var initialSpecificValue: String? // TODO: handle geolocation too

        enum CodingKeys: String, CodingKey {
            case multiline
            case showLabelWhenReadOnly = "show-label-when-read-only"
            case choices
            case items
            case actions
            case initialSpecificValue = "initial-specific-value"
        }
    }

    class Action: Codable {
        var command: Command?
        var field: String?
        var value: Value?

        func call(elements: [Element], fieldValues: [String: FieldValue?]) -> [String: FieldValue?] {
            switch command {
            case .none: return fieldValues
            case .setValue:
                guard let field = field else {
                    print("Field for SET VALUE command not set")
                    return fieldValues
                }
                guard let fieldObject = elements.first(where: { $0.id == field }) else {
                    print("Field for SET VALUE command not found")
                    return fieldValues
                }
                guard let dataType = fieldObject.attributes.dataType else {
                    print("Field data type for SET VALUE command not set")
                    return fieldValues
                }
                guard let options = fieldObject.attributes.options else {
                    print("Field options for SET VALUE command not set")
                    return fieldValues
                }
                guard let value = value else {
                    print("Value for SET VALUE command not set")
                    return fieldValues
                }

                let concreteValue = value.call(fieldDataType: dataType, options: options)
                var newFieldValues = fieldValues // arrays have value semantics, so it's copied
                newFieldValues[field] = concreteValue
                return newFieldValues
            case .addDays:
                // TODO: to implement
                return fieldValues
//                guard let value = value else {
//                    print("Value for SET VALUE command not set")
//                    return fieldValues
//                }
//
//                let now = Date()
//                guard let field = field else {
//                    print("Field for SET VALUE command not set")
//                    return fieldValues
//                }
//                guard let fieldObject = elements.first(where: { $0.id == field }) else {
//                    print("Field for SET VALUE command not found")
//                    return fieldValues
//                }
//
//                guard let numDays = Int(value) else {
//                    print("Invalid number of days: \(numDays)")
//                    return fieldValues
//                }
//
//                var updatedDate: Date!
//                switch fieldObject.attributes.dataType {
//                case .date:
//                    let startDate = DateUtils.date(fromServerString: fieldValues[field])
//                    updatedDate = DateUtils.addDays(startDate, Int())
//                case .dateTime:
//                    let startDate = DateTimeUtils.date(fromServerString: fieldValues[field])
//                default:
//                    print("Invalide data type for ADD DAYS")
//                    return fieldValues
//                }
//
//                let updatedDate =
            }
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
