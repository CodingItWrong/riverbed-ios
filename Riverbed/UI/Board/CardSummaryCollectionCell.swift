import UIKit

protocol ColumnCellDelegate: AnyObject {
    func didSelect(card: Card)
    func getPreview(forCard card: Card) -> CardViewController
    func didSelect(preview viewController: CardViewController)
    func update(card: Card, with fieldValues: [String: FieldValue?])
    func delete(card: Card)
    func edit(column: Column)
    func delete(column: Column)
}

class CardSummaryCollectionCell: UICollectionViewCell,
                                 UIContextMenuInteractionDelegate,
                                 UITextViewDelegate {

    weak var delegate: ColumnCellDelegate?

    @IBOutlet var fieldStack: UIStackView! {
        didSet { configureCardView() }
    }

    private var card: Card?
    var elements: [Element]?
    var elementViews = [String: UIView]()

    var summaryElements: [Element] {
        let elements = elements?.filter { $0.attributes.showInSummary } ?? []
        return elements.inDisplayOrder
    }

    func configureCardView() {
        layer.cornerRadius = 10.0
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        focusEffect = UIFocusHaloEffect()

    }

    func configureData(card: Card, elements: [Element]) {
        if elements != self.elements {
            self.elements = elements
            configureElements()
        }

        self.card = card
        configureValues()
    }

    func configureElements() {
        fieldStack.arrangedSubviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        elementViews.removeAll()

        if elements?.isEmpty == true {
            let label = UILabel()
            label.numberOfLines = 3
            label.font = .preferredFont(forTextStyle: .body)
            label.text = "Tap this card to get started!"
            fieldStack.addArrangedSubview(label)
            return
        }

        summaryElements.forEach { (element) in
            if let linkURLs = element.attributes.options?.linkURLs,
               linkURLs {
                let textView = UITextView()
                textView.isUserInteractionEnabled = true
                textView.isEditable = false
                textView.isScrollEnabled = false
                textView.textContainer.lineFragmentPadding = 0
                textView.textContainerInset = .zero
                textView.delegate = self

                elementViews[element.id] = textView
                fieldStack.addArrangedSubview(textView)
            } else {
                let label = UILabel()
                label.numberOfLines = 3
                label.font = .preferredFont(forTextStyle: element.attributes.options?.textSize?.textStyle ?? .body)

                elementViews[element.id] = label
                fieldStack.addArrangedSubview(label)
            }
        }
    }

    func configureValues() {
        guard let card = card else { return }
        summaryElements.forEach { (element) in
            guard let elementView = elementViews[element.id] else {
                print("Could not find label for element \(element.id)")
                return
            }

            var labelText: String?
            let value = singularizeOptionality(card.attributes.fieldValues[element.id])
            if let value = value {
                labelText = element.formatString(from: value)
            } else {
                labelText = nil
            }

            if let label = elementView as? UILabel {
                label.text = labelText
            } else if let textView = elementView as? UITextView {
                if case let .string(urlString) = value,
                   let labelText = labelText {
                    let textStyle =
                    element.attributes.options?.textSize?.textStyle ?? TextSize.defaultTextSize.textStyle
                    if let url = URL(string: urlString),
                       UIApplication.shared.canOpenURL(url) {
                        textView.attributedText = NSAttributedString(string: labelText, attributes: [
                            .font: UIFont.preferredFont(forTextStyle: textStyle),
                            .link: url // NOTE: using a text view as link clicking did not work in label
                       ])
                    } else {
                        textView.attributedText = NSAttributedString(string: labelText, attributes: [
                            .font: UIFont.preferredFont(forTextStyle: textStyle),
                            .foregroundColor: UIColor.label
                        ])
                    }
                    textView.isHidden = false
                } else {
                    textView.attributedText = nil
                    textView.isHidden = true // so it doesn't take up vertical space
                }
            }
        }
    }

    @objc func handleLinkClick(_ sender: UIButton) {
        print("TODO")
        // gotta get back to the right value in here; how to get it?
        guard let card = card,
              let entry = elementViews.first(where: { (_, view) in view == sender }),
              let fieldValue = singularizeOptionality(card.attributes.fieldValues[entry.key]) else { return }

        switch fieldValue {
        case let .string(urlString):
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            } else {
                print("Not a valid URL: \(urlString)")
            }
        default:
            preconditionFailure("Unexpected field value: \(String(describing: fieldValue))")
        }
    }

    // attempts to prevent text selection by immediately deselecting it
    // see https://stackoverflow.com/a/62318084/477480
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedTextRange != nil {
            textView.delegate = nil
            textView.selectedTextRange = nil
            textView.delegate = self
        }
    }

    // MENU: - context menu

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let card = card else {
            preconditionFailure("Expected a card")
        }

        return UIContextMenuConfiguration(identifier: card.id as NSCopying,
                                          previewProvider: {

            return self.delegate?.getPreview(forCard: card)
        },
                                          actionProvider: { _ in
            let customElements: [UIMenuElement] = {
                guard let elements = self.elements else { return [] }

                return elements
                    .filter { (element: Element) in
                        let elementTypesToInclude: Set<Element.ElementType> = [.button, .buttonMenu]
                        if !elementTypesToInclude.contains(element.attributes.elementType) {
                            return false
                        } else if let showConditions = element.attributes.showConditions {
                            return checkConditions(fieldValues: card.attributes.fieldValues,
                                                   conditions: showConditions,
                                                   elements: elements)
                        } else {
                            return true
                        }
                    }
                    .map { element in
                        switch element.attributes.elementType {
                        case .button:
                            return UIAction(title: element.attributes.name ?? "(unnamed button)") { _ in
                                guard let actions = element.attributes.options?.actions else { return }
                                let updatedFieldValues = Riverbed.apply(actions: actions,
                                                                        to: card.attributes.fieldValues,
                                                                        elements: elements)
                                self.delegate?.update(card: card, with: updatedFieldValues)
                            }
                        case .buttonMenu:
                            let items: [Element.Item] = element.attributes.options?.items ?? []
                            let buttonActions = items.map { (item: Element.Item) in
                                return UIAction(title: item.name) { _ in
                                    guard let actions = item.actions else { return }
                                    let updatedFieldValues = Riverbed.apply(actions: actions,
                                                                            to: card.attributes.fieldValues,
                                                                            elements: elements)
                                    self.delegate?.update(card: card, with: updatedFieldValues)
                                }
                            }
                            return UIMenu(title: element.attributes.name ?? "(unnamed menu)", children: buttonActions)
                        default:
                            preconditionFailure(
                                "Unexpected element type \(String(describing: element.attributes.elementType))")
                        }
                    }
            }()

            let deleteAction = UIAction(title: "Delete", attributes: [.destructive]) { [weak self] _ in
                // deleted the wrong card! did it preview the wrong one too?
                self?.delegate?.delete(card: card)
            }
            let menuElements = customElements + [deleteAction]

            return UIMenu(children: menuElements)
        })
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                                animator: UIContextMenuInteractionCommitAnimating) {
        animator.preferredCommitStyle = .pop
        guard let cardVC = animator.previewViewController as? CardViewController else {
            preconditionFailure("Expected a CardViewController")
        }
        animator.addCompletion {
            self.delegate?.didSelect(preview: cardVC)
        }
    }
}
