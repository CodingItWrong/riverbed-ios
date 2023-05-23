import UIKit

class ColumnCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var title: UILabel!
    @IBOutlet var tableView: UITableView!

    @IBOutlet weak var delegate: CardSummaryDelegate?

    var column: Column? {
        didSet {
            title.text = column?.attributes.name ?? ""
            updateCardGroups()
        }
    }
    var cards = [Card]() {
        didSet { updateCardGroups() }
    }
    var elements = [Element]() {
        didSet { updateCardGroups() }
    }

    var cardGroups = [CardGroup]()

    var sortedCards: [Card] {
        cards.reversed() // newest first
    }

    private func updateCardGroups() {
        guard let column = column else { return }

        cardGroups = Card.group(cards: sortedCards, for: column, with: elements)

        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        cardGroups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cardGroups[section].cards.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let column = column,
              let cardGrouping = column.attributes.cardGrouping,
              let groupFieldId = cardGrouping.field,
              let groupField = elements.first(where: { $0.id == groupFieldId }),
              let groupValue = cardGroups[section].value else {
            return "(empty)"
        }

        return groupField.formatString(from: groupValue)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if let cell = cell as? CardSummaryCell {
            let card = cardGroups[indexPath.section].cards[indexPath.row]
            cell.configureData(card: card, elements: elements)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = sortedCards[indexPath.row]
        delegate?.cardSelected(card)
        tableView.deselectRow(at: indexPath, animated: true) // TODO: may not need if we change it to tap the card
    }
}

// when this was a struct, incrementally creating them didn't seem to work
class CardGroup {
    var value: FieldValue?
    var cards: [Card]

    init(value: FieldValue? = nil, cards: [Card]) {
        self.value = value
        self.cards = cards
    }
}
