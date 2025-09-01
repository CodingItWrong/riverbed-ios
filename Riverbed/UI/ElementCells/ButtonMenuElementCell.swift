import UIKit

class ButtonMenuElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate?

    var allElements: [Element]!

    @IBOutlet private(set) var menuButton: UIButton! {
        didSet {
            if #available(iOS 26, *) {
                menuButton.configuration = .prominentGlass()
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
        self.allElements = allElements

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

        let fieldValues = delegate.fieldValues // get the latest at the time it executes

        let updatedFieldValues = apply(actions: actions,
                                       to: fieldValues,
                                       elements: allElements)

        delegate.update(values: updatedFieldValues, dismiss: true)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        menuButton.isEnabled = !editing
    }
}
