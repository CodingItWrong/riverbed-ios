import UIKit

class SwitchCell: UITableViewCell {

    weak var delegate: FormCellDelegate?

    @IBOutlet var label: UILabel!
    @IBOutlet var switchControl: UISwitch! {
        didSet {
            switchControl.addTarget(self,
                                    action: #selector(didChangeValue(_:)),
                                    for: .valueChanged)
        }
    }

    @objc func didChangeValue(_ sender: UISwitch) {
        delegate?.valueDidChange(inFormCell: self)
    }

}
