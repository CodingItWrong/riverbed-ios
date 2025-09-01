import UIKit

class ButtonElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate? // not used

    var buttonElement: Element!
    var allElements: [Element]!

    @IBOutlet private(set) var button: UIButton! {
        didSet {
            if #available(iOS 26, *) {
                button.configuration = .prominentGlass()
            }
        }
    }
    
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
        leadingConstraint.constant = constant
        trailingConstraint.constant = constant
    }
    
    func update(for element: Element, allElements: [Element], fieldValue: FieldValue?) {
        self.buttonElement = element
        self.allElements = allElements

        button.setTitle(element.attributes.name, for: .normal)
    }

    @IBAction func clickButton(_ sender: UIButton) {
        guard let delegate = delegate,
        let actions = buttonElement.attributes.options?.actions else { return }

        let fieldValues = delegate.fieldValues // get the latest at the time it executes

        let updatedFieldValues = apply(actions: actions,
                                       to: fieldValues,
                                       elements: allElements)

        delegate.update(values: updatedFieldValues, dismiss: true)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        button.isEnabled = !editing
    }
}
