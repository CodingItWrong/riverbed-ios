import UIKit

class ButtonMenuElementCell: UITableViewCell, ElementCell {

    @IBOutlet private(set) var menuButton: UIButton!

    func update(for element: Element, and card: Card) {
        menuButton.setTitle(element.attributes.name, for: .normal)
        let items = element.attributes.options?.items ?? []
        let menuOptions = items.map { (item) in
            UIAction(title: item.name) { _ in
                print("Tapped \(item.name)")
            }
        }
        menuButton.menu = UIMenu(children: menuOptions)
    }
}
