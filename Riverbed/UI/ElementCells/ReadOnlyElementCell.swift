import UIKit

class ReadOnlyElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate? // not used

    @IBOutlet var valueLabel: UILabel!

    @IBOutlet private(set) var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var trailingConstraint: NSLayoutConstraint!

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        configureForCurrentSizeClass()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        configureForCurrentSizeClass()
    }
    
    func configureForCurrentSizeClass() {
        let constant = traitCollection.horizontalSizeClass == .compact ? 16.0 : 20.0
        
        print("updating constraint constants to \(constant)")
        leadingConstraint.constant = constant + 6 // inset to line up with other elements' labels
        trailingConstraint.constant = constant
    }
    
    func update(for element: Element, allElements: [Element], fieldValue: FieldValue?) {
        if let value = fieldValue {
            valueLabel.text = element.formatString(from: value)
        } else if isEditing {
            valueLabel.text = element.attributes.name ?? "(unnamed field)"
        } else {
            valueLabel.text = ""
        }
    }

}
