import UIKit

@objc protocol CardSummaryDelegate: AnyObject {
    func cardSelected(_ card: Card)
}

class CardSummaryCell: UITableViewCell {
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
                let link = UIButton()
                var configuration = UIButton.Configuration.plain()
                configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                link.configuration = configuration
                let textStyle = element.attributes.options?.textSize?.textStyle ?? .body
                link.titleLabel?.font = .preferredFont(forTextStyle: textStyle)
                link.contentHorizontalAlignment = .leading
                link.addTarget(self,
                               action: #selector(handleLinkClick(_:)),
                               for: .touchUpInside)

                elementViews[element.id] = link
                fieldStack.addArrangedSubview(link)
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
            if let value = singularizeOptionality(card.attributes.fieldValues[element.id]) {
                labelText = element.formatString(from: value)
            } else {
                labelText = ""
            }

            if let label = elementView as? UILabel {
                label.text = labelText
            } else if let link = elementView as? UIButton {
                link.setTitle(labelText, for: .normal)
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
}
