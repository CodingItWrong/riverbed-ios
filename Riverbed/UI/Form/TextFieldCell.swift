import UIKit

class TextFieldCell: UITableViewCell, UITextFieldDelegate {

    weak var delegate: FormCellDelegate?

    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField! {
        didSet {
            textField.layer.cornerRadius = 5
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.separator.cgColor
        }
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.valueDidChange(inFormCell: self)
    }

}
