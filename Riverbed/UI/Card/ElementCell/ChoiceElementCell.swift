import UIKit

class ChoiceElementCell: UITableViewCell, ElementCell {

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var valuePopUpButton: UIButton!

    func update(for element: Element, and card: Card) {
        elementLabel.text = element.attributes.name
        let choices = element.attributes.options?.choices ?? []
        let menuOptions = choices.map { (choice) in
            UIAction(title: choice.label) { _ in
                print("Tapped \(choice.id)")
            }
        }
        valuePopUpButton.menu = UIMenu(children: menuOptions)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        valuePopUpButton.isEnabled = !editing
    }
}
