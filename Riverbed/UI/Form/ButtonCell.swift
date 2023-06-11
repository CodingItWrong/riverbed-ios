import UIKit

class ButtonCell: UITableViewCell {

    weak var delegate: FormCellDelegate?

    @IBOutlet var label: UILabel!
    @IBOutlet var button: UIButton!

    @IBAction func pressButton() {
        delegate?.didPressButton(inFormCell: self)
    }

}
