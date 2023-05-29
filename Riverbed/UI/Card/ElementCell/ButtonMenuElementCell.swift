import UIKit

class ButtonMenuElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate?

    var allElements: [Element]!
    var fieldValues: [String: FieldValue?]!

    @IBOutlet private(set) var menuButton: UIButton!

    func update(for element: Element, allElements: [Element], fieldValues: [String: FieldValue?]) {
        self.allElements = allElements
        self.fieldValues = fieldValues

        menuButton.setTitle(element.attributes.name, for: .normal)
        let items = element.attributes.options?.items ?? []
        let menuOptions = items.map { (item) in
            UIAction(title: item.name) { [weak self] _ in
                self?.tappedItem(item)
            }
        }
        menuButton.menu = UIMenu(children: menuOptions)
    }

    func tappedItem(_ item: Element.Item) {
        guard let delegate,
              let actions = item.actions else { return }

        actions.forEach { (action) in
            fieldValues = action.call(elements: allElements, fieldValues: fieldValues)
        }
        delegate.update(values: fieldValues, dismiss: true)
    }
}
