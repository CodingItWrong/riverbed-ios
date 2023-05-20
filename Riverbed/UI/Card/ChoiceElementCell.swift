import UIKit

class ChoiceElementCell: UITableViewCell, ElementCell {

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var valuePopUpButton: UIButton!

    func update(for element: Element, and card: Card) {
        elementLabel.text = element.attributes.name

        // TODO: figure out how to configure options for the pop-up button menu
    }
}
