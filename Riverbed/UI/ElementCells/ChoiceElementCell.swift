import UIKit

class ChoiceElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate?

    private var element: Element?

    @IBOutlet private(set) var elementLabel: UILabel!

    @IBOutlet private(set) var valuePopUpButton: UIButton! {
        didSet {
            if #available(iOS 26, *) {
                valuePopUpButton.configuration = .glass()
            }
        }
    }


    func update(for element: Element, allElements: [Element], fieldValue: FieldValue?) {
        self.element = element

        let choices: [Element.Choice?] = [nil] + (element.attributes.options?.choices ?? [])
        let currentChoice = choices.first { (choice) in
            if let choice = choice {
                guard let value = fieldValue,
                      case let .string(stringValue) = value else { return false }
                return choice.id == stringValue
            } else {
                return fieldValue == nil
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
