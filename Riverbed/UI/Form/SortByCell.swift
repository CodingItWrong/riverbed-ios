import UIKit

class SortByCell: UITableViewCell {

    weak var delegate: FormCellDelegate?

    @IBOutlet var label: UILabel!
    @IBOutlet var fieldButton: UIButton!
    @IBOutlet var directionButton: UIButton!

    var selectedField: Element?
    var selectedDirection: Column.Direction?

    func configure(_ sortOrder: Column.SortOrder?, fields: [Element]) {
        selectedField = fields.first { $0.id == sortOrder?.field }
        selectedDirection = sortOrder?.direction

        let emptyFieldOption = UIAction(title: "(field)",
                                        state: UIMenuElement.State.stateFor(isSelected: isSelected)) { [weak self] _ in
                 guard let self = self else { return }
                 self.selectedField = nil
                 self.delegate?.valueDidChange(inFormCell: self)
             }
        let fieldOptions = fields.inDisplayOrder.map { (field) in
            let state = UIMenuElement.State.stateFor(isSelected: field == selectedField)
            return UIAction(title: field.attributes.name ?? "(unnamed field)", state: state) { [weak self] _ in
                guard let self = self else { return }
                self.selectedField = field
                self.delegate?.valueDidChange(inFormCell: self)
            }
        }
        fieldButton.menu = UIMenu(children: [emptyFieldOption] + fieldOptions)

        directionButton.menu = UIMenu(children: [
            UIAction(title: "(direction)",
                     state: UIMenuElement.State.stateFor(isSelected: selectedDirection == nil)) { [weak self] _ in
                         guard let self = self else { return }
                         self.selectedDirection = nil
                         self.delegate?.valueDidChange(inFormCell: self)
            },
            UIAction(
                title: Column.Direction.ascending.label,
                state: UIMenuElement.State.stateFor(isSelected: selectedDirection == .ascending)) { [weak self] _ in
                         guard let self = self else { return }
                         self.selectedDirection = .ascending
                         self.delegate?.valueDidChange(inFormCell: self)
            },
            UIAction(
                title: Column.Direction.descending.label,
                state: UIMenuElement.State.stateFor(isSelected: selectedDirection == .descending)) { [weak self] _ in
                         guard let self = self else { return }
                         self.selectedDirection = .descending
                         self.delegate?.valueDidChange(inFormCell: self)
            }
        ])
    }
}
