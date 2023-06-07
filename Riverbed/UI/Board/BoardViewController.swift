import UIKit

class BoardViewController: UIViewController,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout,
                           BoardListDelegate,
                           CardSummaryDelegate,
                           CardViewControllerDelegate {

    // MARK: - properties

    @IBOutlet var columnsCollectionView: UICollectionView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!

    var cardStore: CardStore!
    var columnStore: ColumnStore!
    var elementStore: ElementStore!

    var cards = [Card]()
    var columns = [Column]()
    var elements = [Element]()

    private var titleButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    var board: Board! {
        didSet {
            titleButton.configuration?.title = board.attributes.name ?? Board.defaultName
            navigationItem.rightBarButtonItem?.isEnabled = false // until elements loaded

            configureTint()
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
            UIAction(title: "Delete", attributes: [.destructive]) { _ in print("delete") }
        ])
        titleButton.menu = menu
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
        let tintColor = board.attributes.colorTheme?.uiColor ?? ColorTheme.defaultUIColor

        navigationController?.navigationBar.tintColor = tintColor // plus button on iPad
        navigationItem.leftBarButtonItem?.tintColor = tintColor // back button on iPad portrait

        // navigation bar title
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: tintColor]
        navigationItem.standardAppearance = appearance

        [
            UIButton.appearance(), // also affects plus button on iPhone only
            UIDatePicker.appearance(),
            UITextField.appearance(),
            UITextView.appearance()
        ].forEach { $0.tintColor = tintColor }
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
        cardStore.create(on: board, with: elements) { [weak self] (result) in
            switch result {
            case let .success(card):
                self?.cardSelected(card)
            case let .failure(error):
                print("Error creating card: \(String(describing: error))")
            }
        }
    }

    @objc func refreshBoardData(_ sender: UIRefreshControl?) {
        loadBoardData(from: sender)
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

    // MARK: - collection view data source and delegate

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
        default:
            preconditionFailure("Unexpected segue")
        }
    }

}
