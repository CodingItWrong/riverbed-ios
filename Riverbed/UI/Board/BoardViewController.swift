import UIKit

protocol BoardDelegate: AnyObject {
    func didUpdate(board: Board)
    func didDelete(board: Board)
    func didDismiss(board: Board)
}

class BoardViewController: UIViewController,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout,
                           BoardListDelegate,
                           ColumnCellDelegate,
                           CardViewControllerDelegate,
                           EditBoardViewControllerDelegate {

    // MARK: - properties

    weak var delegate: BoardDelegate?

    @IBOutlet var columnsCollectionView: UICollectionView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!

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
            } else {
                titleButton.configuration?.title = "(choose or create a board)"
            }
            navigationItem.rightBarButtonItem?.isEnabled = false // until elements loaded

            if board?.id != oldValue?.id {
                // do not update tint or icon when saving updates to the current board
                configureTint()
                if let board = board {
                    let image = board.attributes.icon?.image ?? Icon.defaultBoardImage
                    // let scaledImage = image.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .small))
                    titleButton.setImage(image, for: .normal)
                } else {
                    titleButton.setImage(nil, for: .normal)
                }
            }
            titleButton.sizeToFit()

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let board = board else { return }

        // hass to be *before* the main view shows, for the button color change to show
        delegate?.didDismiss(board: board)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearBoardData()
    }

    // MARK: - data management

    func clearBoardData() {
        cards = []
        columns = []
        elements = []

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

    func configureTint() {
        // do not run while VC is showing; issue on iPhone only where updating button tint breaks nav bar
        print("BoardViewController.configureTint")
        guard let board = board else { return }

        let tintColor = board.attributes.colorTheme?.uiColor ?? ColorTheme.defaultUIColor

        // iPad and Mac: affects all navigation bar elements (because a separate nav controller
        navigationController?.navigationBar.tintColor = tintColor
    }

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
                self?.cardSelected(card)
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
                                         style: .default) {[weak self] _ in
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

    func cardSelected(_ card: Card) {
        performSegue(withIdentifier: "showCardDetail", sender: card)
    }

    func cardDidUpdate(_ card: Card) {
        // Could consider only reloading the cards
        loadBoardData()
    }

    func cardWasDeleted(_ card: Card) {
        loadBoardData()
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

    func boardDidUpdate(_ board: Board) {
        self.board = board
        delegate?.didUpdate(board: board) // propagate the change
        // TODO: probably don't actually need to reload child objects at this point
        // but maybe nice for fresh data
    }

    // MARK: - collection view data source and delegate

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        columns.count + (board == nil ? 0 : 1)
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

    // MARK: - segues

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

        default:
            preconditionFailure("Unexpected segue")
        }
    }

}
