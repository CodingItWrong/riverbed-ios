import UIKit

protocol BoardDelegate: AnyObject {
    func didUpdate(board: Board)
    func didDelete(board: Board)
}

class BoardViewController: UIViewController,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout,
                           BoardListDelegate,
                           ColumnCellDelegate,
                           CardViewControllerDelegate,
                           EditBoardViewControllerDelegate,
                           EditColumnViewControllerDelegate {

    // MARK: - properties

    weak var delegate: BoardDelegate?

    @IBOutlet var columnsCollectionView: UICollectionView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!

    var isFirstLoadingBoard = true

    var boardStore: BoardStore!
    var cardStore: CardStore!
    var columnStore: ColumnStore!
    var elementStore: ElementStore!

    var cards = [Card]()
    var columns = [Column]()
    var elements = [Element]()

    private var titleButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.showsMenuAsPrimaryAction = true
        button.configuration?.imagePadding = 5
        return button
    }()

    var board: Board? {
        didSet {
            if let board = board {
                titleButton.configuration?.title = board.attributes.name ?? Board.defaultName
                let image = board.attributes.icon?.image ?? Icon.defaultBoardImage
                // let scaledImage = image.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .small))
                titleButton.setImage(image, for: .normal)
                titleButton.sizeToFit()

                // when a board is set (including edited),
                // set the whole split view controller's tint color to the board's
                updateSplitViewTintColorForBoard()
            } else {
                titleButton.configuration?.title = "(choose or create a board)"
                titleButton.setImage(nil, for: .normal)
            }

            navigationItem.rightBarButtonItem?.isEnabled = false // until elements loaded
            clearBoardData()
            loadBoardData()
        }
    }

    var sortedColumns = [Column]()

    func updateSortedColumns() {
        sortedColumns = columns.sorted { (lhs, rhs) in
            guard let lhsOrder = lhs.attributes.displayOrder else { return false }
            guard let rhsOrder = rhs.attributes.displayOrder else { return true }
            return lhsOrder < rhsOrder
        }
    }

    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = titleButton

        let menu = UIMenu(children: [
            UIAction(title: "Board Settings") { [weak self] _ in
                self?.performSegue(withIdentifier: "editBoard", sender: nil)
            },
            UIAction(title: "Delete Board", attributes: [.destructive]) { [weak self] _ in
                self?.deleteBoard()
            }
        ])
        titleButton.menu = menu
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // needed here as the splitViewController is not available at the start of the segue
        updateSplitViewTintColorForBoard()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearBoardData()
    }

    func configureForForeground() {
        // title button is lost in background on iPad and we need to restore it here
        navigationItem.titleView = nil
        navigationItem.titleView = titleButton
    }

    // MARK: - data management

    func clearBoardData() {
        cards = []
        columns = []
        elements = []
        isFirstLoadingBoard = true

        updateSortedColumns()

        columnsCollectionView.reloadData()
    }

    func loadBoardData(from refreshControl: UIRefreshControl? = nil) {
        guard let board = board else { return }

        if refreshControl == nil {
            loadingIndicator.startAnimating()
        }

        var areCardsLoading = true
        var areColumnsLoading = true
        var areElementsLoading = true

        func checkForLoadingDone() {
            let loadingDone = !areCardsLoading && !areColumnsLoading && !areElementsLoading
            if loadingDone {
                isFirstLoadingBoard = false
                if let refreshControl = refreshControl {
                    refreshControl.endRefreshing()
                } else {
                    loadingIndicator.stopAnimating()
                }
                self.columnsCollectionView.reloadData()
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }

        print("LOADING CARDS")
        cardStore.all(for: board) { (result) in
            switch result {
            case let .success(cards):
                self.cards = cards
            case let .failure(error):
                print("Error loading cards: \(error)")
            }
            areCardsLoading = false
            checkForLoadingDone()
        }
        columnStore.all(for: board) { (result) in
            switch result {
            case let .success(columns):
                self.columns = columns
                self.updateSortedColumns()
            case let .failure(error):
                print("Error loading columns: \(error)")
            }
            areColumnsLoading = false
            checkForLoadingDone()
        }
        elementStore.all(for: board) { (result) in
            switch result {
            case let .success(elements):
                self.elements = elements
            case let .failure(error):
                print("Error loading elements: \(error)")
            }
            areElementsLoading = false
            checkForLoadingDone()
        }
    }

    // MARK: - layout and visuals

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        configureForCurrentSizeClass()
        columnsCollectionView.collectionViewLayout.invalidateLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureForCurrentSizeClass()
    }

    func configureForCurrentSizeClass() {
        let isPagingEnabled = self.traitCollection.horizontalSizeClass == .compact
//        print("configureForCurrentSizeClass, isPagingEnabled = \(isPagingEnabled)")
        columnsCollectionView.isPagingEnabled = isPagingEnabled
    }

    func updateSplitViewTintColorForBoard() {
        guard let board = board,
              let splitViewController = splitViewController else { return }

        splitViewController.view.tintColor = board.attributes.colorTheme?.uiColor ?? ColorTheme.defaultUIColor
    }

    // MARK: - actions

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(addCard(_:)) {
            return navigationItem.rightBarButtonItem?.isEnabled ?? false
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

    @IBAction func addCard(_ sender: Any?) {
        guard let board = board else { return }

        cardStore.create(on: board, with: elements) { [weak self] (result) in
            switch result {
            case let .success(card):
                self?.didSelect(card)
            case let .failure(error):
                print("Error creating card: \(String(describing: error))")
            }
        }
    }

    @IBAction func addColumn(_ sender: Any?) {
        guard let board = board else { return }

        columnStore.create(on: board) { [weak self] (result) in
            switch result {
            case .success:
                self?.loadBoardData()
            case let .failure(error):
                print("Error creating column: \(String(describing: error))")
            }
        }
    }

    @objc func refreshBoardData(_ sender: Any?) {
        let refreshControl = sender as? UIRefreshControl
        loadBoardData(from: refreshControl)
    }

    func deleteBoard() {
        guard let board = board else { return }

        let boardDescriptor = board.attributes.name ?? "this board"
        let message = "Are you sure you want to delete \(boardDescriptor)? " +
                      "All data will be lost and cannot be recovered."
        let alert = UIAlertController(title: "Delete Board?",
                                      message: message,
                                      preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .destructive) {[weak self] _ in
               guard let self = self else { return }

               boardStore.delete(board) { [weak self] (result) in
                   switch result {
                   case .success:
                       self?.delegate?.didDelete(board: board)
                       self?.board = nil
                   case let .failure(error):
                       print("Error deleting card: \(String(describing: error))")
                   }
               }
           }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.preferredAction = deleteAction

        present(alert, animated: true)
    }

    // MARK: - app-specific delegates

    func didSelect(board: Board) {
        // TODO: consider if we need to reload the Board from the server
        self.board = board
    }

    func didSelect(_ card: Card) {
        performSegue(withIdentifier: "showCardDetail", sender: card)
    }

    func didUpdate(_ card: Card) {
        // Could consider only reloading the cards
        loadBoardData()
    }

    func didDelete(_ card: Card) {
        loadBoardData()
    }

    func edit(_ column: Column) {
        performSegue(withIdentifier: "editColumn", sender: column)
    }

    func delete(_ column: Column) {
        let columnDescriptor = column.attributes.name ?? "this board"
        let message = "Are you sure you want to delete \(columnDescriptor)? " +
                      "Cards in this column will still be available in other columns."
        let alert = UIAlertController(title: "Delete Column?",
                                      message: message,
                                      preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .destructive) {[weak self] _ in
            guard let self = self else { return }

            columnStore?.delete(column) { [weak self] (result) in
                switch result {
                case .success:
                    self?.loadBoardData()
                case let .failure(error):
                    print("Error creating column: \(String(describing: error))")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.preferredAction = deleteAction

        present(alert, animated: true)
    }

    func delete(_ card: Card) {
        let alert = UIAlertController(title: "Delete?",
                                      message: "Are you sure you want to delete this card?",
                                      preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .destructive) {[weak self] _ in
               guard let self = self else { return }

               cardStore.delete(card) { [weak self] (result) in
                   switch result {
                   case .success:
                       self?.loadBoardData()
                   case let .failure(error):
                       print("Error deleting card: \(String(describing: error))")
                   }
               }
           }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.preferredAction = deleteAction

        present(alert, animated: true)
    }

    func didUpdate(_ board: Board) {
        self.board = board
        delegate?.didUpdate(board: board) // propagate the change
        // TODO: probably don't actually need to reload child objects at this point
        // but maybe nice for fresh data
    }

    func didUpdate(_ column: Column) {
        loadBoardData()
    }

    // MARK: - collection view data source and delegate

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFirstLoadingBoard || board == nil {
            return 0
        } else {
            return columns.count + 1
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat
        if self.traitCollection.horizontalSizeClass == .compact {
            width = view.bounds.width
        } else {
            width = 400
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
        // add column
        if indexPath.row >= sortedColumns.count {
            return columnsCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: UICollectionViewCell.self),
                for: indexPath)
        }

        guard let cell = columnsCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ColumnCell.self),
            for: indexPath) as? ColumnCell else { preconditionFailure("Expected a ColumnCell") }

        let column = sortedColumns[indexPath.row]

        cell.cardStore = cardStore
        cell.column = column
        cell.elements = elements
        cell.cards = cards
        cell.delegate = self

        if cell.tableView.refreshControl == nil {
            cell.tableView.refreshControl = UIRefreshControl()
            cell.tableView.refreshControl?.addTarget(self,
                                                     action: #selector(self.refreshBoardData(_:)),
                                                     for: .valueChanged)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        if sourceIndexPath == destinationIndexPath {
            return
        }

        // move in local data
        let movedColumn = sortedColumns[sourceIndexPath.row]
        sortedColumns.remove(at: sourceIndexPath.row)
        sortedColumns.insert(movedColumn, at: destinationIndexPath.row)

        // persist to server
        columnStore.updateDisplayOrders(of: sortedColumns) { (result) in
            if case let .failure(error) = result {
                print("Error updating display orders: \(String(describing: error))")
            }
        }
    }

    @IBAction func moveColumn(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizer.State.began:
            guard let selectedIndexPath = columnsCollectionView.indexPathForItem(
                at: gesture.location(in: columnsCollectionView))
            else { return }
            columnsCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizer.State.changed:
            columnsCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizer.State.ended:
            columnsCollectionView.endInteractiveMovement()
        default:
            columnsCollectionView.cancelInteractiveMovement()
        }
    }

    // MARK: - segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        // when opening a modal, set its tint color to the parent split view controller's
        segue.destination.view.tintColor = splitViewController?.view.tintColor

        switch segue.identifier {
        case "showCardDetail":
            guard let cardVC = segue.destination as? CardViewController else {
                preconditionFailure("Expected CardViewController")
            }
            guard let card = sender as? Card else {
                preconditionFailure("Expected Card")
            }

            cardVC.delegate = self
            cardVC.board = board
            cardVC.elements = elements
            cardVC.elementStore = elementStore
            cardVC.cardStore = cardStore // TODO: setter order dependency unfortunate
            cardVC.card = card

        case "editBoard":
            guard let editBoardVC = segue.destination as? EditBoardViewController else {
                preconditionFailure("Expected EditBoardViewController")
            }

            editBoardVC.delegate = self
            editBoardVC.board = board
            editBoardVC.elements = elements
            editBoardVC.boardStore = boardStore

        case "editColumn":
            guard let navigationVC = segue.destination as? UINavigationController else {
                preconditionFailure("Expected UINavigationController")
            }
            guard let editColumnVC = navigationVC.viewControllers.first as? EditColumnViewController else {
                preconditionFailure("Expected EditColumnViewController")
            }
            guard let column = sender as? Column else { preconditionFailure("Expected a Column") }

            editColumnVC.column = column
            editColumnVC.elements = elements
            editColumnVC.columnStore = columnStore
            editColumnVC.delegate = self

        default:
            preconditionFailure("Unexpected segue")
        }
    }

}
