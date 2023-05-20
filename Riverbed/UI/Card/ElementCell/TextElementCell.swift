import UIKit

class TextElementCell: UITableViewCell, ElementCell {

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var valueTextField: UITextField!

    func update(for element: Element, and card: Card) {
        elementLabel.text = element.attributes.name

        let value = card.attributes.fieldValues[element.id]
        if case let .string(stringValue) = value {
            valueTextField.text = stringValue
        }

        switch element.attributes.dataType {
        case .text:
            valueTextField.keyboardType = .default
        case .number:
            valueTextField.keyboardType = .decimalPad
            // TODO: disallow entering alphabetic characters with a bluetooth keyboard
        default:
            // TODO: remove this when all cases covered
            valueTextField.keyboardType = .default
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        valueTextField.isEnabled = !editing
    }

}
