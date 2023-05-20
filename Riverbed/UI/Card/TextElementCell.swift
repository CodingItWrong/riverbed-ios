import UIKit

class TextElementCell: UITableViewCell {

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var valueTextField: UITextField!

    func update(for element: Element, and card: Card) {
        elementLabel.text = element.attributes.name

        let value = card.attributes.fieldValues[element.id]
        if case let .string(stringValue) = value {
            valueTextField.text = stringValue
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        valueTextField.isEnabled = !editing
    }

}
