import UIKit

class SummaryCell: UITableViewCell {

    weak var delegate: FormCellDelegate?

    @IBOutlet var label: UILabel!
    @IBOutlet var functionButton: UIButton!
    @IBOutlet var fieldButton: UIButton!

    var selectedFunction: SummaryFunction? {
        didSet { updateForSelection() }
    }
    var selectedField: Element?

    func configure(_ summary: Column.Summary?, fields: [Element]) {

        selectedFunction = summary?.function
        selectedField = fields.first { $0.id == summary?.field }

        let emptyFieldAction = UIAction(
            title: "(field)",
            state: UIMenuElement.State.stateFor(isSelected: selectedField == nil)) { [weak self] _ in
                guard let self = self else { return }
                self.selectedField = nil
                self.delegate?.valueDidChange(inFormCell: self)
        }
        let fieldActions = fields.inDisplayOrder.map { (field) in
            let state = UIMenuElement.State.stateFor(isSelected: field == selectedField)
            return UIAction(title: field.attributes.name ?? "(unnamed field)", state: state) { [weak self] _ in
                guard let self = self else { return }
                self.selectedField = field
                self.delegate?.valueDidChange(inFormCell: self)
            }
        }
        fieldButton.menu = UIMenu(children: [emptyFieldAction] + fieldActions)

        let emptyFunctionAction = UIAction(
            title: "(function)",
            state: UIMenuElement.State.stateFor(isSelected: selectedFunction == nil)) { [weak self] _ in
                guard let self = self else { return }
                self.selectedFunction = nil
                self.delegate?.valueDidChange(inFormCell: self)
        }
        let functionActions = SummaryFunction.allCases.map { (summaryFunction) in
            UIAction(
                title: summaryFunction.label,
                state: UIMenuElement.State.stateFor(isSelected: selectedFunction == summaryFunction)) { [weak self] _ in
                         guard let self = self else { return }
                         self.selectedFunction = summaryFunction
                         self.delegate?.valueDidChange(inFormCell: self)
            }
        }
        functionButton.menu = UIMenu(children: [emptyFunctionAction] + functionActions)
    }

    private func updateForSelection() {
        let showField = selectedFunction?.hasField ?? false
        fieldButton.isHidden = !showField
    }
}
