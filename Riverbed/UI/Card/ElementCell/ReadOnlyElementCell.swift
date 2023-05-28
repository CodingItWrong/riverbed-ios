import UIKit

class ReadOnlyElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate? // not used

    @IBOutlet var valueLabel: UILabel!

    func update(for element: Element, and card: Card) {
        if let value = singularizeOptionality(card.attributes.fieldValues[element.id]) {
            let formattedValue = element.formatString(from: value)

            // TODO: summary may need to take this into account too, in which case this could live in a helper
            if let showLabelWhenReadOnly = element.attributes.options?.showLabelWhenReadOnly,
               showLabelWhenReadOnly,
               let fieldName = element.attributes.name {
                valueLabel.text = "\(fieldName): \(formattedValue ?? "")"
            } else {
                valueLabel.text = formattedValue
            }
        } else {
            valueLabel.text = ""
        }
    }

}
