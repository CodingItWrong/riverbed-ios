import UIKit

class ChoiceElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate?

    private var element: Element?

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var valuePopUpButton: UIButton!

    func update(for element: Element, and card: Card) {
        self.element = element

        let choices = element.attributes.options?.choices ?? []
        let currentChoice = choices.first {
            guard let value = card.attributes.fieldValues[element.id],
                  case let .string(stringValue) = value  else { return false }
            return $0.id == stringValue
        }

        elementLabel.text = element.attributes.name
        let menuOptions = choices.map { (choice) in
            let state: UIMenuElement.State = choice == currentChoice ? .on : .off
            return UIAction(title: choice.label, state: state) {
                [weak self] _ in

                self?.passUpdatedValueToDelegate(choice)
            }
        }

        valuePopUpButton.menu = UIMenu(children: menuOptions)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        valuePopUpButton.isEnabled = !editing
    }

    func passUpdatedValueToDelegate(_ choice: Element.Choice) {
        guard let element = element else { return }
        delegate?.update(value: .string(choice.id), for: element)
    }
}
