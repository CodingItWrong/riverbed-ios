import UIKit

class CollectionViewColumnCell: UICollectionViewCell,
                                UICollectionViewDelegate {

    enum CardCollectionItem: Hashable {
        case card(Card)
        case noCards
    }

    weak var delegate: ColumnCellDelegate?

    @IBOutlet var title: UILabel!
    @IBOutlet var columnMenuButton: UIButton!
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            configureCollectionView()
        }
    }

    var dataSource: UICollectionViewDiffableDataSource<FieldValue?, CardCollectionItem>!

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

        updateSnapshot()
    }

    // MARK: - data

    func configureCollectionView() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(100.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 10,
                                                     bottom: 0,
                                                     trailing: 10)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0),
                                                         top: .fixed(10),
                                                         trailing: .fixed(0),
                                                         bottom: .fixed(10))

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(100.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitems: [item])

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(10)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: 0,
                                                        bottom: 10,
                                                        trailing: 0)
        section.boundarySupplementaryItems = [sectionHeader]
        let layout = UICollectionViewCompositionalLayout(section: section)

        collectionView.collectionViewLayout = layout
//        collectionView.allowsFocus = true

        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: UICollectionView.elementKindSectionHeader) {
            [weak self] (supplementaryView, _, indexPath) in
                guard let self = self else { return }
                supplementaryView.label.text = self.label(forSectionAt: indexPath) ?? ""
        }

        let cellIdentifier = String(describing: CardSummaryCollectionCell.self)
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil),
                                forCellWithReuseIdentifier: cellIdentifier)

        dataSource = UICollectionViewDiffableDataSource<FieldValue?, CardCollectionItem>(
            collectionView: collectionView, cellProvider: {
            collectionView, indexPath, cardCollectionItem in

                switch cardCollectionItem {
                case .noCards:
                    return collectionView.dequeueReusableCell(withReuseIdentifier: "noCards", for: indexPath)
                case let .card(card):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: cellIdentifier, for: indexPath) as? CardSummaryCollectionCell
                    else { preconditionFailure("Expected a CardSummaryCollectionCell")}
                    cell.configureData(card: card, elements: self.elements)
                    cell.delegate = self.delegate // forward the delegate so cell can call directly through to it
                    return cell
                }
        })
        dataSource.supplementaryViewProvider = { (collectionView, _, index) in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }

        collectionView.dataSource = dataSource
    }

    private func label(forSectionAt indexPath: IndexPath) -> String? {
        guard cardGroups.count > 0 else {
            return nil
        }

        guard let column = column,
              let cardGrouping = column.attributes.cardGrouping,
              let groupFieldId = cardGrouping.field,
              let groupField = elements.first(where: { $0.id == groupFieldId }) else {
            return nil
        }

        guard let groupValue = cardGroups[indexPath.section].value else {
            return "(empty)"
        }

        return groupField.formatString(from: groupValue)
    }

    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<FieldValue?, CardCollectionItem>()

        if cardGroups.isEmpty {
            snapshot.appendSections([nil])
            snapshot.appendItems([.noCards])
        } else {
            cardGroups.forEach { (group) in
                snapshot.appendSections([group.value])
                snapshot.appendItems(group.cards.map { .card($0) })
            }
        }

        // animation looks mostly good on iOS, but bad on Mac
//        let animatingDifferences = !ProcessInfo.processInfo.isiOSAppOnMac
        let animatingDifferences = true // while separate column cells, may also have trouble with full-card hashing

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    // MARK: - collection view delegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = card(for: indexPath)
        delegate?.didSelect(card: card)
        collectionView.deselectItem(at: indexPath, animated: true)
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
        delegate.edit(column: column)
    }

    @IBAction func deleteColumn(_ sender: Any?) {
        guard let delegate = delegate,
              let column = column else { return }
        delegate.delete(column: column)
    }

}
