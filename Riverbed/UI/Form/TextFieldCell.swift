import UIKit

class TextFieldCell: UITableViewCell, UITextFieldDelegate {

    weak var delegate: FormCellDelegate?

    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField!

    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.valueDidChange(inFormCell: self)
    }

}
