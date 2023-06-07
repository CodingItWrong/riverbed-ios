import UIKit

protocol ElementCellDelegate: AnyObject {
    var fieldValues: [String: FieldValue?] { get }

    func update(value: FieldValue?, for element: Element)
    func update(values: [String: FieldValue?], dismiss: Bool)
}

protocol ElementCell: UITableViewCell {
    var delegate: ElementCellDelegate? { get set }

    func update(for element: Element, allElements: [Element], fieldValue: FieldValue?)
}

func elementCellType(for element: Element) -> UITableViewCell.Type {
    switch element.attributes.elementType {
    case .button: return ButtonElementCell.self
    case .buttonMenu: return ButtonMenuElementCell.self
    case .field:
        switch element.attributes.dataType {
        case .choice: return ChoiceElementCell.self
        case .date: return DateElementCell.self
        case .dateTime: return DateElementCell.self
        case .geolocation: return GeolocationElementCell.self
        case .number: return TextElementCell.self
        case .text: return TextElementCell.self
        case .none: return TextElementCell.self
        }
    }
}
