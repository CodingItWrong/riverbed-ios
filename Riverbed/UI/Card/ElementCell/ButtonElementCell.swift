import UIKit

class ButtonElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate? // not used

    var buttonElement: Element!
    var allElements: [Element]!

    @IBOutlet private(set) var button: UIButton!

    func update(for element: Element, allElements: [Element], fieldValues: [String: FieldValue?]) {
        self.buttonElement = element
        self.allElements = allElements
        // self.fieldValues = fieldValues // no; needs to be the latest ones

        button.setTitle(element.attributes.name, for: .normal)
    }

    @IBAction func clickButton(_ sender: UIButton) {
        guard let delegate else { return }

        var fieldValues = delegate.fieldValues // get the latest at the time it executes
        print("tapped button \(sender.titleLabel?.text), fieldValues \(String(describing: fieldValues))")

        buttonElement.attributes.options?.actions?.forEach { (action) in
            fieldValues = action.call(elements: allElements, fieldValues: fieldValues)
        }
        delegate.update(values: fieldValues, dismiss: true)
    }
}
