import UIKit

class PopUpButtonCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var popUpButton: UIButton!

    weak var delegate: FormCellDelegate?

    var selectedValue: Any?

    func configure(options: [Option]) {
        selectedValue = singularizeOptionality(options.first { $0.isSelected }.map { $0.value })
        popUpButton.menu = UIMenu(children: options.map { (option) in
            let state: UIMenuElement.State = option.isSelected ? .on : .off
            return UIAction(title: option.title, image: option.image, state: state) { [weak self] _ in
                guard let self = self else { return }
                self.selectedValue = option.value
                self.delegate?.valueDidChange(inFormCell: self)
            }
        })
    }

    struct Option {
        let title: String
        let image: UIImage?
        let value: Any?
        let isSelected: Bool

        init(title: String, image: UIImage? = nil, value: Any?, isSelected: Bool) {
            self.title = title
            self.image = image
            self.value = value
            self.isSelected = isSelected
        }
    }

}

extension Array<PopUpButtonCell.Option> {
    func withEmptyOption(image: UIImage? = nil,
                         isSelected: Bool) -> [PopUpButtonCell.Option] {
        let emptyOption = PopUpButtonCell.Option(title: "(none)", image: image, value: nil, isSelected: isSelected)
        return [emptyOption] + self
    }
}
