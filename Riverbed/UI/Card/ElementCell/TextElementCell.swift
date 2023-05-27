import UIKit

class TextElementCell: UITableViewCell, ElementCell, UITextFieldDelegate, UITextViewDelegate {

    weak var delegate: ElementCellDelegate?

    private var element: Element?

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var layoutStack: UIStackView!
    @IBOutlet private(set) var valueTextField: UITextField!
    @IBOutlet private(set) var valueTextView: UITextView!

    func update(for element: Element, and card: Card) {
        self.element = element

        [valueTextField, valueTextView].forEach { (field) in
            field?.layer.cornerRadius = 5
            field?.layer.borderWidth = 1
            field?.layer.borderColor = UIColor.separator.cgColor
        }

        updateFormFieldShown(for: element)
        elementLabel.text = element.attributes.name

        let value = card.attributes.fieldValues[element.id]
        if case let .string(stringValue) = value {
            valueTextField.text = stringValue
            valueTextView.text = stringValue
        } else {
            valueTextField.text = ""
            valueTextView.text = ""
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        passUpdatedValueToDelegate(valueTextField.text)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        passUpdatedValueToDelegate(valueTextView.text)
    }

    func passUpdatedValueToDelegate(_ value: String?) {
        guard let element = element,
              let value = value else { return }
        delegate?.update(value: .string(value), for: element)
    }

}
