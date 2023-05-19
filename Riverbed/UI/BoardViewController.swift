import UIKit

class BoardViewController: UIViewController,
                           BoardListDelegate,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout {

    @IBOutlet var columnsCollectionView: UICollectionView!

    var cardStore: CardStore!
    var columnStore: ColumnStore!
    var elementStore: ElementStore!

    var cards = [Card]()
    var columns = [Column]()
    var elements = [Element]()

    var board: Board? {
        didSet { updateForBoard() }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        configureForCurrentSizeClass()
        columnsCollectionView.collectionViewLayout.invalidateLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureForCurrentSizeClass()
    }

    func didSelect(board: Board) {
        // TODO: consider if we need to reload the Board from the server
        self.board = board
    }

    func updateForBoard() {
        guard let board = board else { return }

        navigationItem.title = board.attributes.name

        cardStore.all(for: board) { (result) in
            switch result {
            case let .success(cards):
                self.cards = cards
                self.columnsCollectionView.reloadData()
            case let .failure(error):
                print("Error loading cards: \(error)")
            }
        }
        columnStore.all(for: board) { (result) in
            switch result {
            case let .success(columns):
                self.columns = columns
                self.columnsCollectionView.reloadData()
            case let .failure(error):
                print("Error loading columns: \(error)")
            }
        }
        elementStore.all(for: board) { (result) in
            switch result {
            case let .success(elements):
                self.elements = elements
                self.columnsCollectionView.reloadData()
            case let .failure(error):
                print("Error loading elements: \(error)")
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        columns.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            preconditionFailure("Expected a UICollectionViewFlowLayout")
        }

        var width: CGFloat
        if self.traitCollection.horizontalSizeClass == .compact {
            width = view.bounds.width - layout.minimumInteritemSpacing
        } else {
            width = 300
        }
        let height = collectionView.frame.size.height
            - collectionView.safeAreaInsets.top
            - collectionView.safeAreaInsets.bottom
        // this may be due to "cells should not extend outside the safe area insets",
        // which may not apply in my case to allow scrolling into the unsafe area

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = columnsCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ColumnCell.self),
            for: indexPath) as? ColumnCell else { preconditionFailure("Unexpected cell class") }
        let column = columns[indexPath.row]

        cell.title.text = column.attributes.name
        cell.elements = elements
        cell.cards = cards

        return cell
    }

    func configureForCurrentSizeClass() {
        let isPagingEnabled = self.traitCollection.horizontalSizeClass == .compact
//        print("configureForCurrentSizeClass, isPagingEnabled = \(isPagingEnabled)")
        columnsCollectionView.isPagingEnabled = isPagingEnabled
    }

}

class ColumnCell: UICollectionViewCell, UITableViewDataSource {
    @IBOutlet var title: UILabel!
    @IBOutlet var tableView: UITableView!

    var cards = [Card]() {
        didSet { tableView.reloadData() }
    }
    var elements = [Element]() {
        didSet { tableView.reloadData() }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cards.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if let cell = cell as? CardSummaryCell {
            let card = cards[indexPath.row]
            cell.configureData(card: card, elements: elements)
        }

        return cell
    }
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
        print("RECONFIGURING ELEMENTS FOR A CELL INSTANCE")
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
