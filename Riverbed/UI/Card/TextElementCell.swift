import UIKit

class TextElementCell: UITableViewCell {

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var valueTextField: UITextField!

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        valueTextField.isEnabled = !editing
    }

}
