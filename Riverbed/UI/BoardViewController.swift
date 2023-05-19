import UIKit

class BoardViewController: UIViewController,
                           BoardListDelegate,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout {

    @IBOutlet var columnsCollectionView: UICollectionView!

    var cardStore: CardStore!
    var columnStore: ColumnStore!

    var cards = [Card]()
    var columns = [Column]()

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
        let height = collectionView.frame.size.height -
            collectionView.contentInset.top -
            collectionView.contentInset.bottom

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = columnsCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ColumnCell.self),
            for: indexPath) as? ColumnCell else { preconditionFailure("Unexpected cell class") }
        let column = columns[indexPath.row]

        cell.title.text = column.attributes.name
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cards.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let card = cards[indexPath.row]

        cell.textLabel?.text = "Card \(card.id)"

        return cell
    }
}
