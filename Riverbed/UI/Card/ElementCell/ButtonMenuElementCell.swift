import UIKit

class ButtonMenuElementCell: UITableViewCell, ElementCell {

    @IBOutlet private(set) var menuButton: UIButton!

    func update(for element: Element, and card: Card) {
//        menuButton.titleLabel?.text = element.attributes.name
        print("TODO - seems like maybe it's a UIMenu instead")
    }
}
