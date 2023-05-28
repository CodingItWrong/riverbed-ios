import UIKit

class BoardViewController: UIViewController,
                           BoardListDelegate,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout,
                           CardSummaryDelegate,
                           CardViewControllerDelegate {
    @IBOutlet var columnsCollectionView: UICollectionView!

    var cardStore: CardStore!
    var columnStore: ColumnStore!
    var elementStore: ElementStore!

    var cards = [Card]()
    var columns = [Column]()
    var elements = [Element]()

    var board: Board! {
        didSet {
            clearBoardData()
            loadBoardData()
        }
    }

    var sortedColumns: [Column] {
        columns.sorted { (lhs, rhs) in
            guard let lhsOrder = lhs.attributes.displayOrder else { return false }
            guard let rhsOrder = rhs.attributes.displayOrder else { return true }
            return lhsOrder < rhsOrder
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        configureForCurrentSizeClass()
        columnsCollectionView.collectionViewLayout.invalidateLayout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearBoardData()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureForCurrentSizeClass()
    }

    func didSelect(board: Board) {
        // TODO: consider if we need to reload the Board from the server
        self.board = board
    }

    func clearBoardData() {
        cards = []
        columns = []
        elements = []

        columnsCollectionView.reloadData()
    }

    @objc func loadBoardData(_ sender: UIRefreshControl? = nil) {
        navigationItem.title = board.attributes.name

        cardStore.all(for: board) { (result) in
            // TODO: do this after all the loads complete
            // Deferred or async/await?
            sender?.endRefreshing()
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
        var width: CGFloat
        if self.traitCollection.horizontalSizeClass == .compact {
            width = view.bounds.width
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

        let column = sortedColumns[indexPath.row]

        cell.column = column
        cell.elements = elements
        cell.cards = cards
        cell.delegate = self

        if cell.tableView.refreshControl == nil {
            cell.tableView.refreshControl = UIRefreshControl()
            cell.tableView.refreshControl?.addTarget(self,
                                                     action: #selector(self.loadBoardData),
                                                     for: .valueChanged)
        }

        return cell
    }

    func configureForCurrentSizeClass() {
        let isPagingEnabled = self.traitCollection.horizontalSizeClass == .compact
//        print("configureForCurrentSizeClass, isPagingEnabled = \(isPagingEnabled)")
        columnsCollectionView.isPagingEnabled = isPagingEnabled
    }

    func cardSelected(_ card: Card) {
        performSegue(withIdentifier: "showCardDetail", sender: card)
    }

    @IBAction func addCard(_ sender: UIBarButtonItem) {
        cardStore.create(on: board, with: elements) { [weak self] (result) in
            switch result {
            case let .success(card):
                self?.cardSelected(card)
            case let .failure(error):
                print("Error creating card: \(String(describing: error))")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "showCardDetail":
            guard let cardVC = segue.destination as? CardViewController else {
                preconditionFailure("Expected CardViewController")
            }
            guard let card = sender as? Card else {
                preconditionFailure("Expected Card")
            }

            cardVC.delegate = self
            cardVC.elements = elements
            cardVC.card = card
            cardVC.cardStore = cardStore
        default:
            preconditionFailure("Unexpected segue")
        }
    }

    func cardDidUpdate(_ card: Card) {
        // Could consider only reloading the cards
        loadBoardData()
    }

    func cardWasDeleted(_ card: Card) {
        loadBoardData()
    }

}
