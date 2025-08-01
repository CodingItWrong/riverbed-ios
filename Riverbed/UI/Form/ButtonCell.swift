import UIKit

class ButtonCell: UITableViewCell {

    weak var delegate: FormCellDelegate?

    @IBOutlet var label: UILabel!
    
    @IBOutlet private(set) var button: UIButton! {
        didSet {
            if #available(iOS 26, *) {
                button.configuration = .prominentGlass()
            }
        }
    }


    @IBAction func pressButton() {
        delegate?.didPressButton(inFormCell: self)
    }

}
