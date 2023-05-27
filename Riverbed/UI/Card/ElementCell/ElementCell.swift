import UIKit

protocol ElementCellDelegate: AnyObject {
    func update(value: FieldValue?, for element: Element)
}

protocol ElementCell: UITableViewCell {
    var delegate: ElementCellDelegate? { get set }

    func update(for element: Element, and card: Card)
}
