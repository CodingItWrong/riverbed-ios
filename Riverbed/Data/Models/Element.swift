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

    class Attributes: Codable {
        var name: String?
        var elementType: Element.ElementType
        var dataType: Element.DataType?
        var showInSummary: Bool
        var options: Element.Options?

        enum CodingKeys: String, CodingKey {
            case name
            case elementType = "element-type"
            case dataType = "data-type"
            case showInSummary = "show-in-summary"
            case options
        }
    }

    class Options: Codable {
        var multiline: Bool?
        var choices: [Element.Choice]?
        var items: [Element.Item]?
    }

    class Choice: Codable {
        var id: String
        var label: String
    }

    class Item: Codable {
        var name: String
        // TODO: actions
    }
}
