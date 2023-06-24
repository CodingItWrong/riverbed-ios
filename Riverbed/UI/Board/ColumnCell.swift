import UIKit

protocol ColumnCellDelegate: AnyObject {
    func didSelect(_ card: Card)
    func getPreview(forCard card: Card) -> CardViewController
    func didSelect(preview viewController: CardViewController)
    func delete(_ card: Card)
    func edit(_ column: Column)
    func delete(_ column: Column)
}

class ColumnCell: UICollectionViewCell,
                  UIContextMenuInteractionDelegate,
                  UITableViewDataSource,
                  UITableViewDelegate {
    @IBOutlet var title: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var columnMenuButton: UIButton!

    weak var delegate: ColumnCellDelegate?

    var cardStore: CardStore!

    var column: Column? {
        didSet {
            updateColumnTitle()
        }
    }
    private func updateColumnTitle() {
        guard let column = column else { return }

        let titleText = column.attributes.name ?? "(column)"

        if let summaryText = calculate(summary: column.attributes.summary) {
            title.text = "\(titleText) (\(summaryText))"
        } else {
            title.text = titleText
        }
    }
    var cards = [Card]() {
        didSet { updateFilteredCards() }
    }
    var elements = [Element]() {
        didSet { updateFilteredCards() }
    }

    var filteredCards = [Card]() {
        didSet {
            updateColumnTitle()
            updateCardGroups()
        }
    }
    private func updateFilteredCards() {
        guard let column = column else { return }

        filteredCards = Card.filter(cards: cards, for: column, with: elements)
    }

    var cardGroups = [CardGroup]()
    private func updateCardGroups() {
        guard let column = column else { return }

        cardGroups = Card.group(cards: filteredCards, for: column, with: elements)

        tableView.reloadData()
    }

    // MARK: - table view data source and delegate

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
            if cardGroups.count == 1 {
                return nil
            } else {
                return "(empty)"
            }
        }

        return groupField.formatString(from: groupValue)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CardSummaryCell.self),
                                                 for: indexPath)

        if let cell = cell as? CardSummaryCell {
            let card = card(for: indexPath)
            cell.configureData(card: card, elements: elements)
            let interaction = UIContextMenuInteraction(delegate: self)
            cell.cardView.addInteraction(interaction)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = card(for: indexPath)
        delegate?.didSelect(card)
        tableView.deselectRow(at: indexPath, animated: true) // TODO: may not need if we change it to tap the card
    }

    // MARK: - context menu interaction delegate

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let delegate = delegate else {
            preconditionFailure("Expected a delegate")
        }
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            preconditionFailure("Could not find an indexPath for point")
        }
        let card = card(for: indexPath)

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath,
                                          previewProvider: {

            return delegate.getPreview(forCard: card)
        },
                                          actionProvider: { _ in
            return UIMenu(children: [
                UIAction(title: "Delete", attributes: [.destructive]) { [weak self] _ in
                    // deleted the wrong card! did it preview the wrong one too?
                    self?.delegate?.delete(card)
                }
            ])
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

    // MARK: - private helpers

    private func card(for indexPath: IndexPath) -> Card {
        cardGroups[indexPath.section].cards[indexPath.row]
    }

    private func calculate(summary: Column.Summary?) -> String? {
        guard let summary = summary,
              let summaryFunction = summary.function else { return nil }

        switch summaryFunction {
        case .count:
            return String(filteredCards.count)
        case .sum:
            guard let summaryFieldId = summary.field else { return nil }
            let values: [Decimal] = filteredCards
                .map { (card) in
                    if let value = singularizeOptionality(card.attributes.fieldValues[summaryFieldId]),
                       case let .string(valueString) = value,
                       let valueNumber = Decimal(string: valueString) {
                        return valueNumber
                    } else {
                        return 0
                    }
                }
            let sum = values.reduce(0, +)
            return "\(sum)"
        }
    }

    // MARK: - actions

    @IBAction func showColumnSettings(_ sender: Any?) {
        guard let delegate = delegate,
              let column = column else { return }
        delegate.edit(column)
    }

    @IBAction func deleteColumn(_ sender: Any?) {
        guard let delegate = delegate,
              let column = column else { return }
        delegate.delete(column)
    }

}
