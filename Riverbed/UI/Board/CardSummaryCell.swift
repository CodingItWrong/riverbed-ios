import UIKit

@objc protocol CardSummaryDelegate: AnyObject {
    func cardSelected(_ card: Card)
}

class CardSummaryCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet var cardView: UIView! {
        didSet { configureCardView() }
    }
    @IBOutlet var fieldStack: UIStackView!

    private var card: Card?
    var elements: [Element]?
    var elementViews = [String: UIView]()

    var summaryElements: [Element] {
        let elements = elements?.filter { $0.attributes.showInSummary } ?? []
        return elements.sorted(by: Element.areInIncreasingOrder(lhs:rhs:))
    }

    func configureCardView() {
        cardView.layer.cornerRadius = 5.0
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

            var labelText: String!
            let value = singularizeOptionality(card.attributes.fieldValues[element.id])
            if let value = value {
                labelText = element.formatString(from: value) ?? ""
            } else {
                labelText = ""
            }

            if let label = elementView as? UILabel {
                label.text = labelText
            } else if let textView = elementView as? UITextView {
                if case let .string(urlString) = value,
                   let url = URL(string: urlString) {
                    let textStyle = element.attributes.options?.textSize?.textStyle ?? TextSize.defaultTextSize.textStyle
                    textView.attributedText = NSAttributedString(string: labelText, attributes: [
                        .font: UIFont.preferredFont(forTextStyle: textStyle),
                        .link: url // NOTE: using a text view as link clicking did not work in label
                    ])
                } else {
                    textView.attributedText = NSAttributedString(string: "")
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
}
