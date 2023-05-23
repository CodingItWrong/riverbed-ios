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
        // filter
        var filteredCards: [Card]
        if let cardInclusionConditions = column?.attributes.cardInclusionConditions {
            filteredCards = cards.filter { (card) in
                checkConditions(fieldValues: card.attributes.fieldValues,
                                conditions: cardInclusionConditions,
                                elements: elements)
            }
        } else {
            filteredCards = cards
        }

        // TODO: are choice labels used for choice fields?

        // sort
        var sortedCards: [Card]
        if let cardSortOrder = column?.attributes.cardSortOrder {
            sortedCards = sort(cards: filteredCards, by: cardSortOrder)
        } else {
            sortedCards = filteredCards
        }

        // group
        let cardGrouping = column?.attributes.cardGrouping
        cardGroups = group(cards: sortedCards, by: cardGrouping, elements: elements)

        tableView.reloadData()
    }

    private func checkConditions(fieldValues: [String: FieldValue?],
                                 conditions: [Condition]?,
                                 elements: [Element]) -> Bool {
        guard let conditions = conditions else {
            return true
        }

        return conditions.allSatisfy { (condition) in
            guard let field = condition.field,
                  let query = condition.query,
                  field != "" else {
                return true
            }

            let fieldObject = elements.first { $0.id == field }
            guard let dataType = fieldObject?.attributes.dataType else {
                return true
            }
            var value: FieldValue?
            if let tempValue = fieldValues[field] {
                value = tempValue // attempt to handle a double optional
            }
            return query.match(value: value, dataType: dataType, options: condition.options)
        }
    }

    private func sort(cards: [Card], by sortOrder: Column.SortOrder) -> [Card] {
        guard let field = sortOrder.field,
              let direction = sortOrder.direction else {
            return cards
        }

        let sortedCards = cards.sorted { (cardA, cardB) in
            guard let aValue = cardA.attributes.fieldValues[field],
                  case let .string(aValue) = aValue else { return true }
            guard let bValue = cardB.attributes.fieldValues[field],
                  case let .string(bValue) = bValue else { return false }
            return aValue < bValue
        }
        switch direction {
        case .ascending: return sortedCards
        case .descending: return sortedCards.reversed()
        }
    }

    private func group(cards: [Card],
                       by cardGrouping: Column.SortOrder?,
                       elements: [Element]) -> [CardGroup] {
        guard let cardGrouping = cardGrouping,
              let field = cardGrouping.field,
              let direction = cardGrouping.direction,
              let groupField = elements.first(where: { $0.id == field }) else {
            if cards.isEmpty {
                return []
            } else {
                return [CardGroup(value: nil, cards: cards)]
            }
        }

        print("3")

        var cardGroups = [CardGroup]()

        cards.forEach { (card) in
            let groupValue: FieldValue? = {
                if let groupValue = card.attributes.fieldValues[field] {
                    return groupValue
                } else {
                    return nil
                }
            }()

            if let existingGroup = cardGroups.first(where: { $0.value == groupValue }) {
                existingGroup.cards.append(card)
            } else {
                let newGroup = CardGroup(value: groupValue, cards: [card])
                cardGroups.append(newGroup)
            }
        }

        // TODO: sort nil first
        let sortedCardGroups = cardGroups.sorted { (lhs, rhs) in
            guard let aValue = groupField.sortValue(from: lhs.value) else { return true }
            guard let bValue = groupField.sortValue(from: rhs.value) else { return false }

            return aValue > bValue
        }

//        print("total cards: \(cards.count)")
//        sortedCardGroups.forEach { (group) in
//            print("group \(group.value) with \(group.cards.count) cards")
//        }

        switch direction {
        case .ascending: return sortedCardGroups
        case .descending: return sortedCardGroups.reversed()
        }
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
