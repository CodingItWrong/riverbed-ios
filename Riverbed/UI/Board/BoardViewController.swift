import UIKit

protocol BoardDelegate: AnyObject {
    func didUpdate(board: Board)
    func didDelete(board: Board)
}

class BoardViewController: UIViewController,
                           UICollectionViewDelegateFlowLayout,
                           BoardListDelegate,
                           ColumnCellDelegate,
                           CardViewControllerDelegate,
                           EditBoardViewControllerDelegate,
                           EditColumnDelegate {

    enum ColumnCollectionItem: Hashable {
        case column(Column)
        case add
    }

    // MARK: - properties

    weak var delegate: BoardDelegate?

    @IBOutlet var columnsCollectionView: UICollectionView! {
        didSet {
            columnsCollectionView.contentInsetAdjustmentBehavior = .always
            configureCollectionView()
        }
    }
    @IBOutlet var firstLoadIndicator: UIActivityIndicatorView!
    @IBOutlet var reloadIndicator: UIActivityIndicatorView!
    @IBOutlet var errorContainer: UIView!

    var isLoadingBoard = false
    var isFirstLoadingBoard = true

    var boardStore: BoardStore!
    var cardStore: CardStore!
    var columnStore: ColumnStore!
    var elementStore: ElementStore!

    var cards = [Card]()
    var columns = [Column]()
    var elements = [Element]()

    var dataSource: UICollectionViewDiffableDataSource<String, ColumnCollectionItem>!

    private var titleButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.showsMenuAsPrimaryAction = true
        button.configuration?.imagePadding = 5
        return button
    }()

    var board: Board? {
        didSet {
            // when a board is set (including edited),
            // set the whole split view controller's tint color to the board's
            updateSplitViewTintColorForBoard()

            if let windowScene = view.window?.windowScene,
                let board = board {
                windowScene.title = board.attributes.name ?? "Riverbed"
            }
            
            if #available(iOS 16.0, *) {
                if let board = board {
//                    navigationItem.title = board.attributes.name ?? Board.defaultName

                    let image = board.attributes.icon?.image ?? Icon.defaultBoardImage

                    let titleLbl = UILabel()
                    titleLbl.text = board.attributes.name ?? Board.defaultName
                    titleLbl.font = .preferredFont(forTextStyle: .title3)
                    let imageView = UIImageView(image: image)
                    let titleView = UIStackView(arrangedSubviews: [imageView, titleLbl])
                    titleView.axis = .horizontal
                    titleView.alignment = .center
                    titleView.spacing = 5.0
                    navigationItem.titleView = titleView
                } else {
                    navigationItem.title = "(choose or create a board)"
                }
            } else {
                if let board = board {
                    titleButton.configuration?.title = board.attributes.name ?? Board.defaultName
                    let image = board.attributes.icon?.image ?? Icon.defaultBoardImage
                    // let scaledImage = image.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .small))
                    titleButton.setImage(image, for: .normal)
                    titleButton.sizeToFit()
                } else {
                    titleButton.configuration?.title = "(choose or create a board)"
                    titleButton.setImage(nil, for: .normal)
                }
            }

            if board?.id != oldValue?.id {
                navigationItem.rightBarButtonItem?.isEnabled = false // until elements loaded
                clearBoardData()
                loadBoardData()
            }
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

        if #available(iOS 16.0, *) {
            navigationItem.titleMenuProvider = { _ in
                UIMenu(children: [
                    UIAction(title: "Board Settings") { [weak self] _ in
                        self?.editBoard()
                    },
                    UIAction(title: "Delete Board", attributes: [.destructive]) { [weak self] _ in
                        self?.deleteBoard()
                    }
                ])
            }
        } else {
            navigationItem.titleView = titleButton

            let menu = UIMenu(children: [
                UIAction(title: "Board Settings") { [weak self] _ in
                    self?.editBoard()
                },
                UIAction(title: "Delete Board", attributes: [.destructive]) { [weak self] _ in
                    self?.deleteBoard()
                }
            ])
            titleButton.menu = menu
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // needed here as the splitViewController is not available at the start of the segue
        updateSplitViewTintColorForBoard()
        updateSnapshot()
        updateLoadingErrorDisplay(isError: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearBoardData()
        board = nil
    }

    func configureForForeground() {
        if #unavailable(iOS 16.0) {
            // title button is lost in background on iPad and we need to restore it here
            navigationItem.titleView = nil
            navigationItem.titleView = titleButton
        }
    }

    // MARK: - data management

    func clearBoardData() {
        cards = []
        columns = []
        elements = []
        isFirstLoadingBoard = true

        updateSortedColumns()
        updateSnapshot()
    }

    func updateLoadingErrorDisplay(isError: Bool, refreshControl: UIRefreshControl? = nil) {
        if isLoadingBoard {
            errorContainer?.isHidden = true

            if refreshControl == nil {
                if isFirstLoadingBoard {
                    firstLoadIndicator?.startAnimating()
                } else {
                    reloadIndicator?.startAnimating()
                }
            }
        } else {
            refreshControl?.endRefreshing()
            firstLoadIndicator.stopAnimating()
            reloadIndicator.stopAnimating()

            errorContainer.isHidden = !isError
        }

    }

    @IBAction func loadBoardData(_ sender: Any? = nil) {
        guard let board = board else { return }

        let refreshControl = sender as? UIRefreshControl

        isLoadingBoard = true
        updateLoadingErrorDisplay(isError: false, refreshControl: refreshControl)

        var isError = false
        var areCardsLoading = true
        var areColumnsLoading = true
        var areElementsLoading = true

        func checkForLoadingDone() {
            let loadingDone = !areCardsLoading && !areColumnsLoading && !areElementsLoading
            if !loadingDone {
                return
            }

            isLoadingBoard = false
            updateLoadingErrorDisplay(isError: isError, refreshControl: refreshControl)

            if isError {
                clearBoardData()
                return
            } else {
                isFirstLoadingBoard = false
                updateSnapshot()
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
                isError = true
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
                isError = true
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
                isError = true
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
            guard let self = self else { return }
            switch result {
            case let .success(card):
                self.didSelect(card: card)
            case let .failure(error):
                print("Error creating card: \(String(describing: error))")
                self.showAlert(withErrorMessage: "An error occurred while adding a card.")
            }
        }
    }

    @IBAction func addColumn(_ sender: Any?) {
        guard let board = board else { return }

        columnStore.create(on: board) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.loadBoardData()
            case let .failure(error):
                print("Error creating column: \(String(describing: error))")
                self.showAlert(withErrorMessage: "An error occurred while adding a column.")
            }
        }
    }

    @objc func refreshBoardData(_ sender: Any?) {
        let refreshControl = sender as? UIRefreshControl
        loadBoardData(refreshControl)
    }

    func editBoard() {
        if board != nil {
            performSegue(withIdentifier: "editBoard", sender: nil)
        }
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
                   guard let self = self else { return }
                   switch result {
                   case .success:
                       self.delegate?.didDelete(board: board)
                       self.board = nil
                   case let .failure(error):
                       print("Error deleting card: \(String(describing: error))")
                       self.showAlert(withErrorMessage:
                                        "An error occurred while deleting the board, and it has not been deleted.")
                   }
               }
           }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.preferredAction = deleteAction

        present(alert, animated: true)
    }

    func showAlert(withErrorMessage errorMessage: String) {
        let alert = UIAlertController(title: "Error",
                                      message: errorMessage,
                                      preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        alert.preferredAction = okAction
        present(alert, animated: true)
    }

    // MARK: - app-specific delegates

    func didSelect(board: Board) {
        // TODO: consider if we need to reload the Board from the server
        self.board = board
    }

    func didSelect(card: Card) {
        performSegue(withIdentifier: "showCardDetail", sender: card)
    }

    func getPreview(forCard card: Card) -> CardViewController {
        guard let cardVC = self.storyboard?.instantiateViewController(
            identifier: String(describing: CardViewController.self)) as? CardViewController else {
            preconditionFailure("Expected a VC with identifier \(String(describing: CardViewController.self))")
        }
        prepare(cardViewController: cardVC, with: card)
        cardVC.view.tintColor = view.tintColor
        return cardVC
    }

    func didSelect(preview viewController: CardViewController) {
        viewController.modalPresentationStyle = .formSheet
        present(viewController, animated: false)
    }

    func didUpdate(card: Card) {
        // Could consider only reloading the cards
        loadBoardData()
    }

    func didUpdateElements(forCard card: Card) {
        // Could consider only reloading the cards
        loadBoardData()
    }

    func didDelete(card: Card) {
        loadBoardData()
    }

    func edit(column: Column) {
        performSegue(withIdentifier: "editColumn", sender: column)
    }

    func delete(column: Column) {
        let columnDescriptor = column.attributes.name ?? "this board"
        let message = "Are you sure you want to delete \(columnDescriptor)? " +
                      "Cards in this column will still be available in other columns."
        let alert = UIAlertController(title: "Delete Column?",
                                      message: message,
                                      preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .destructive) {[weak self] _ in
            guard let self = self else { return }

            columnStore.delete(column) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.loadBoardData()
                case let .failure(error):
                    print("Error creating column: \(String(describing: error))")
                    self.showAlert(withErrorMessage: "An error occurred while deleting the column.")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.preferredAction = deleteAction

        present(alert, animated: true)
    }

    func update(card: Card, with fieldValues: [String: FieldValue?]) {
        cardStore.update(card, with: fieldValues) { [weak self] (result) in
            switch result {
            case .success:
                print("SAVED CARD \(card.id)")
                self?.loadBoardData()
            case let .failure(error):
                print("Error saving card: \(String(describing: error))")
            }
        }
    }

    func delete(card: Card) {
        let alert = UIAlertController(title: "Delete?",
                                      message: "Are you sure you want to delete this card?",
                                      preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .destructive) {[weak self] _ in
               guard let self = self else { return }

               cardStore.delete(card) { [weak self] (result) in
                   guard let self = self else { return }
                   switch result {
                   case .success:
                       self.loadBoardData()
                   case let .failure(error):
                       print("Error deleting card: \(String(describing: error))")
                       self.showAlert(withErrorMessage: "An error occurred while deleting the card.")
                   }
               }
           }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.preferredAction = deleteAction

        present(alert, animated: true)
    }

    func didUpdate(board: Board) {
        self.board = board
        delegate?.didUpdate(board: board) // propagate the change
        // TODO: probably don't actually need to reload child objects at this point
        // but maybe nice for fresh data
    }

    func didUpdate(column: Column) {
        loadBoardData()
    }

    // MARK: - collection view data source and delegate

    func configureCollectionView() {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            _, _ in

            let columnHeight: NSCollectionLayoutDimension = .fractionalHeight(1.0)
            let columnWidth: NSCollectionLayoutDimension =
                self.traitCollection.horizontalSizeClass == .compact
                    ? .fractionalWidth(1.0)
                    : .absolute(400)

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: columnWidth,
                                                   heightDimension: columnHeight)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            return section
        }, configuration: config)
        columnsCollectionView.collectionViewLayout = layout
        
        // crashes on Mac for some reason
        if (!ProcessInfo.processInfo.isiOSAppOnMac) {
            columnsCollectionView.contentInsetAdjustmentBehavior = .never
        }

        dataSource = UICollectionViewDiffableDataSource<String, ColumnCollectionItem>(
            collectionView: columnsCollectionView) {
            collectionView, indexPath, columnCollectionItem in

                switch columnCollectionItem {
                case .add:
                    return collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath)
                case let .column(column):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: CollectionViewColumnCell.self),
                        for: indexPath) as? CollectionViewColumnCell
                    else { preconditionFailure("Expected a CollectionViewColumnCell") }

                    cell.delegate = self // needs to come first
                    cell.cardStore = self.cardStore
                    cell.column = column
                    cell.elements = self.elements
                    cell.cards = self.cards

                    if cell.collectionView.refreshControl == nil {
                        cell.collectionView.refreshControl = UIRefreshControl()
                        cell.collectionView.refreshControl?.addTarget(self,
                                                                      action: #selector(self.refreshBoardData(_:)),
                                                                      for: .valueChanged)
                    }

                    return cell
                }
        }
        columnsCollectionView.dataSource = dataSource
    }

    func updateSnapshot() {
        guard let dataSource = dataSource else { return }

        var snapshot = NSDiffableDataSourceSnapshot<String, ColumnCollectionItem>()
        snapshot.appendSections(["DUMMY"])
        snapshot.appendItems(sortedColumns.map { .column($0) })
        if !isFirstLoadingBoard && board != nil {
            snapshot.appendItems([.add])
        }
//        let animatingDifferences = false // results in card cells flashing for some reason
//        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        dataSource.applySnapshotUsingReloadData(snapshot) // this seems to prevent scrolling to the top
    }

    // TODO: turn off or reimplement this
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

            prepare(cardViewController: cardVC, with: card)

        case "editBoard":
            guard let editBoardVC = segue.destination as? EditBoardViewController else {
                preconditionFailure("Expected EditBoardViewController")
            }

            editBoardVC.delegate = self
            editBoardVC.board = board
            editBoardVC.elements = elements
            editBoardVC.boardStore = boardStore

        case "editColumn":
            guard let navigationVC = segue.destination as? EditColumnNavigationController else {
                preconditionFailure("Expected EditColumnNavigationController")
            }
            guard let editColumnVC = navigationVC.viewControllers.first as? EditColumnViewController else {
                preconditionFailure("Expected EditColumnViewController")
            }
            guard let column = sender as? Column else { preconditionFailure("Expected a Column") }

            navigationVC.column = column
            navigationVC.columnStore = columnStore
            navigationVC.editColumnDelegate = self

            editColumnVC.elements = elements

        default:
            preconditionFailure("Unexpected segue")
        }
    }

    func prepare(cardViewController: CardViewController, with card: Card) {
        cardViewController.delegate = self
        cardViewController.board = board
        cardViewController.elements = elements
        cardViewController.elementStore = elementStore
        cardViewController.cardStore = cardStore // TODO: setter order dependency unfortunate
        cardViewController.card = card
    }

}
