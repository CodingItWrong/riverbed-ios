import UIKit

class ButtonElementCell: UITableViewCell, ElementCell {

    @IBOutlet private(set) var button: UIButton!

    func update(for element: Element, and card: Card) {
        button.setTitle(element.attributes.name, for: .normal)
    }

    @IBAction func clickButton(_ sender: UIButton) {
        // TODO: implement
        print("clickButton")
    }
}
