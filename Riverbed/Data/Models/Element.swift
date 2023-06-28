import Foundation

class Element: Codable, Equatable {
    enum ElementType: String, Codable, CaseIterable {
        case field = "field"
        case button = "button"
        case buttonMenu = "button_menu"

        var label: String {
            switch self {
            case .field: return "Field"
            case .button: return "Button"
            case .buttonMenu: return "Button Menu"
            }
        }
    }

    enum DataType: String, Codable, CaseIterable {
        case text = "text"
        case date = "date"
        case number = "number"
        case dateTime = "datetime"
        case choice = "choice"
        case geolocation = "geolocation"

        var label: String {
            switch self {
            case .text: return "Text"
            case .date: return "Date"
            case .number: return "Number"
            case .dateTime: return "Date and Time"
            case .choice: return "Choice"
            case .geolocation: return "Geographic Location"
            }
        }
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
        lhs === rhs
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

        let formattedValue = {
            switch value {
            case let .string(stringValue):
                switch dataType {
                case .text:
                    if let abbreviateURLs = attributes.options?.abbreviateURLs,
                       abbreviateURLs {
                        return domain(for: stringValue)
                    } else {
                        return stringValue
                    }
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
        }()

        if formattedValue != "",
           let showLabelWhenReadOnly = attributes.options?.showLabelWhenReadOnly,
           showLabelWhenReadOnly,
           let fieldName = attributes.name {
            return "\(fieldName): \(formattedValue ?? "")"
        } else {
            return formattedValue
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
        var initialValue: Value?

        init(elementType: Element.ElementType,
             dataType: Element.DataType? = nil,
             options: Element.Options? = nil,
             initialValue: Value? = nil) {
            self.elementType = elementType
            self.dataType = dataType
            self.options = options
            self.initialValue = initialValue
            self.showInSummary = false
            self.readOnly = false
        }

        init(shallowCloning original: Element.Attributes) {
            self.name = original.name
            self.elementType = original.elementType
            self.dataType = original.dataType
            self.showInSummary = original.showInSummary
            self.options = original.options
            self.displayOrder = original.displayOrder
            self.showConditions = original.showConditions
            self.readOnly = original.readOnly
            self.initialValue = original.initialValue
        }

        enum CodingKeys: String, CodingKey {
            case name
            case elementType = "element-type"
            case dataType = "data-type"
            case showInSummary = "show-in-summary"
            case options
            case displayOrder = "display-order"
            case showConditions = "show-conditions"
            case readOnly = "read-only"
            case initialValue = "initial-value"
        }
    }

    class Options: Codable {
        var multiline: Bool?
        var showLabelWhenReadOnly: Bool?
        var choices: [Element.Choice]?
        var items: [Element.Item]?
        var actions: [Action]?
        var initialSpecificValue: FieldValue?
        var textSize: TextSize?
        var abbreviateURLs: Bool?
        var linkURLs: Bool?

        init(multiline: Bool? = nil,
             showLabelWhenReadOnly: Bool? = nil,
             choices: [Element.Choice]? = nil,
             items: [Element.Item]? = nil,
             actions: [Action]? = nil,
             initialSpecificValue: FieldValue? = nil,
             textSize: TextSize? = nil,
             abbreviateURLs: Bool? = nil,
             linkURLs: Bool? = nil) {
            self.multiline = multiline
            self.showLabelWhenReadOnly = showLabelWhenReadOnly
            self.choices = choices
            self.items = items
            self.actions = actions
            self.initialSpecificValue = initialSpecificValue
            self.textSize = textSize
            self.abbreviateURLs = abbreviateURLs
            self.linkURLs = linkURLs
        }

        enum CodingKeys: String, CodingKey {
            case multiline
            case showLabelWhenReadOnly = "show-label-when-read-only"
            case choices
            case items
            case actions
            case initialSpecificValue = "initial-specific-value"
            case textSize = "text-size"
            case abbreviateURLs = "abbreviate-urls"
            case linkURLs = "link-urls"
        }
    }

    class Choice: Codable, Equatable {
        var id: String
        var label: String?

        init(id: String = UUID().uuidString, label: String? = nil) {
            self.id = id
            self.label = label
        }

        static func == (lhs: Element.Choice, rhs: Element.Choice) -> Bool {
            lhs.id == rhs.id
        }
    }

    class Item: Codable {
        var name: String
        var actions: [Action]?
    }
}

class NewElement: Codable {
    let type: String
    var attributes: Element.Attributes
    var relationships: NewElement.Relationships?

    init(attributes: Element.Attributes, relationships: NewElement.Relationships? = nil) {
        self.type = "elements"
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

extension Array<Element> {
    var inDisplayOrder: [Element] {
        sorted(by: Element.areInIncreasingOrder(lhs:rhs:))
    }
}
