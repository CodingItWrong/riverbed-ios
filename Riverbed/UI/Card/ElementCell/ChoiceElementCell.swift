import UIKit

class ChoiceElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate?

    private var element: Element?

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var valuePopUpButton: UIButton!

    func update(for element: Element, and card: Card, allElements: [Element]) {
        self.element = element

        let choices: [Element.Choice?] = [nil] + (element.attributes.options?.choices ?? [])
        let currentChoice = choices.first { (choice) in
            if let choice = choice {
                guard let value = card.attributes.fieldValues[element.id],
                      case let .string(stringValue) = value else { return false }
                return choice.id == stringValue
            } else {
                return card.attributes.fieldValues[element.id] == nil
            }
        }

        elementLabel.text = element.attributes.name
        let menuOptions = choices.map { (choice) in
            let state: UIMenuElement.State = choice == currentChoice ? .on : .off
            return UIAction(title: choice?.label ?? "(choose)", state: state) {
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

    func passUpdatedValueToDelegate(_ choice: Element.Choice?) {
        guard let element = element else { return }

        if let choice = choice {
            delegate?.update(value: .string(choice.id), for: element)
        } else {
            delegate?.update(value: .none, for: element)
        }
    }
}
