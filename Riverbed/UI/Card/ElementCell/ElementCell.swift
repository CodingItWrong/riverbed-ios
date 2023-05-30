import UIKit

protocol ElementCellDelegate: AnyObject {
    var fieldValues: [String: FieldValue?] { get }

    func update(value: FieldValue?, for element: Element)
    func update(values: [String: FieldValue?], dismiss: Bool)
}

protocol ElementCell: UITableViewCell {
    var delegate: ElementCellDelegate? { get set }

    func update(for element: Element, allElements: [Element], fieldValues: [String: FieldValue?])
}
