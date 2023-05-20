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
    var labels = [String: UILabel]()

    var summaryElements: [Element] {
        let elements = elements?.filter { $0.attributes.showInSummary } ?? []
        return elements
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
        labels.removeAll()
        summaryElements.forEach { (element) in
            let label = UILabel()
            label.font = .preferredFont(forTextStyle: .body)

            labels[element.id] = label
            fieldStack.addArrangedSubview(label)
        }
    }

    func configureValues() {
        guard let card = card else { return }
        summaryElements.forEach { (element) in
            guard let label = labels[element.id] else {
                print("Could not find label for element \(element.id)")
                return
            }
            if let value = card.attributes.fieldValues[element.id] {
                switch value {
                case let .string(stringValue):
                    label.text = stringValue
                case .dictionary:
                    label.text = "(TODO: dictionary)"
                }
            } else {
                label.text = ""
            }
        }
    }
}
