import UIKit

class TextElementCell: UITableViewCell, ElementCell {

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var layoutStack: UIStackView!
    @IBOutlet private(set) var valueTextField: UITextField!
    @IBOutlet private(set) var valueTextView: UITextView!

    func update(for element: Element, and card: Card) {
        valueTextView.layer.cornerRadius = 5
        valueTextView.layer.borderWidth = 1
        valueTextView.layer.borderColor = UIColor.separator.cgColor

        updateFormFieldShown(for: element)
        elementLabel.text = element.attributes.name

        let value = card.attributes.fieldValues[element.id]
        if case let .string(stringValue) = value {
            valueTextField.text = stringValue
            valueTextView.text = stringValue
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

    private func updateFormFieldShown(for element: Element) {
        if element.attributes.options?.multiline ?? false {
            addToView(valueTextView)
            removeFromView(valueTextField)
        } else {
            addToView(valueTextField)
            removeFromView(valueTextView)
        }
    }

    private func addToView(_ view: UIView) {
        if view.superview == nil {
            layoutStack.addArrangedSubview(view)
        }
    }

    private func removeFromView(_ view: UIView) {
        if view.superview != nil {
            view.removeFromSuperview()
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        valueTextField.isEnabled = !editing
        valueTextView.isEditable = !editing // because editing the list of elements, not editing their values
    }

}
