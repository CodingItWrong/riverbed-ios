import UIKit

class PopUpButtonCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var popUpButton: UIButton!

    weak var delegate: FormCellDelegate?

    var selectedValue: Any?

    func configure(options: [Option]) {
        selectedValue = options.first { $0.isSelected }.map { $0.value }
        popUpButton.menu = UIMenu(children: options.map { (option) in
            let state: UIMenuElement.State = option.isSelected ? .on : .off
            return UIAction(title: option.title, state: state) { [weak self] _ in
                guard let self = self else { return }
                self.selectedValue = option.value
                self.delegate?.valueDidChange(inFormCell: self)
            }
        })
    }

    struct Option {
        let title: String
        let value: Any?
        let isSelected: Bool
    }

}
