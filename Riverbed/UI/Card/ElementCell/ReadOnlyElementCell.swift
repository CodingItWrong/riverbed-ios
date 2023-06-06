import UIKit

class ReadOnlyElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate? // not used

    @IBOutlet var valueLabel: UILabel!

    func update(for element: Element, allElements: [Element], fieldValue: FieldValue?) {
        if let value = fieldValue {
            valueLabel.text = element.formatString(from: value)
        } else {
            valueLabel.text = ""
        }
    }

}
