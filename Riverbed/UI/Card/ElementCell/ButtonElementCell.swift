import UIKit

class ButtonElementCell: UITableViewCell, ElementCell {

    @IBOutlet private(set) var button: UIButton!

    func update(for element: Element, and card: Card) {
        button.titleLabel?.text = element.attributes.name
    }

    @IBAction func clickButton(_ sender: UIButton) {
        // TODO: implement
        print("clickButton")
    }
}
