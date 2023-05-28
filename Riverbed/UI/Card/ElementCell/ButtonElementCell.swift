import UIKit

class ButtonElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate? // not used

    var buttonElement: Element!
    var allElements: [Element]!
    var fieldValues: [String: FieldValue?]!

    @IBOutlet private(set) var button: UIButton!

    func update(for element: Element, and card: Card, allElements: [Element]) {
        self.buttonElement = element
        self.allElements = allElements
        self.fieldValues = card.attributes.fieldValues

        button.setTitle(element.attributes.name, for: .normal)
    }

    @IBAction func clickButton(_ sender: UIButton) {
        guard let delegate else { return }

        buttonElement.attributes.options?.actions?.forEach { (action) in
            fieldValues = action.call(elements: allElements, fieldValues: fieldValues)
        }
        delegate.update(values: fieldValues, dismiss: true)
    }
}
