import UIKit

class ReadOnlyElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate? // not used

    @IBOutlet var valueLabel: UILabel!

    func update(for element: Element, allElements: [Element], fieldValues: [String: FieldValue?]) {
        if let value = singularizeOptionality(fieldValues[element.id]) {
            valueLabel.text = element.formatString(from: value)
        } else {
            valueLabel.text = ""
        }
    }

}
