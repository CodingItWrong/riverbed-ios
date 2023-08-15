import UIKit

protocol BoardListDelegate: AnyObject {
    func didSelect(board: Board)
}

class BoardListCollectionViewController: UICollectionViewController,
                                         BoardDelegate,
                                         SignInDelegate {

    class BoardGroup {
        var section: Section
        var boards: [Board]

        enum Section: String {
            case favorite = "Favorites"
            case other = "Other Boards"
        }

        init(section: Section, boards: [Board]) {
            self.section = section
            self.boards = boards
        }
    }

    weak var delegate: BoardListDelegate?

    var tokenSource: WritableSessionSource!
    var tokenStore: TokenStore!
    var boardStore: BoardStore!
    var userStore: UserStore!
    var boards = [Board]()
    var dataSource: UICollectionViewDiffableDataSource<BoardGroup.Section, Board>!

    var boardGroups = [BoardGroup]()

    func updateBoardGroups() {
        let temp = Dictionary(grouping: boards) { (board) in
            board.attributes.favoritedAt != nil
        }

        var boardGroups = [BoardGroup]()
        if let favorites = temp[true] {
            boardGroups.append(
                BoardGroup(section: .favorite,
                           boards: favorites.sorted {
                               guard let aFavDate = $0.attributes.favoritedAt,
                                     let bFavDate = $1.attributes.favoritedAt else {
                                   return false
                               }

                               return aFavDate < bFavDate
                           }))
        }
        if let unfavorites = temp[false] {
            boardGroups.append(
                BoardGroup(section: .other,
                           boards: unfavorites.sorted {
                               guard let aName = $0.attributes.name,
                                     let bName = $1.attributes.name else {
                                   return false
                               }

                               return aName < bName
                           }))
        }
        self.boardGroups = boardGroups
        self.updateSnapshot()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let menuButton = navigationItem.rightBarButtonItem else {
            preconditionFailure("Expected a right bar button item")
        }
        menuButton.menu = UIMenu(children: [
            UIMenu(options: .displayInline, children: [
                UIAction(title: "User settings") { _ in
                    self.showUserSettings()
                },
                UIAction(title: "Sign out") { _ in
                    self.signOut()
                    self.checkForSignInFormDisplay()
                }
            ]),
            UIMenu(title: "More info", children: [
                UIAction(title: "About") { _ in
                    self.showAboutPage()
                },
                UIAction(title: "Source code") { _ in
                    self.showSourceCode()
                }
            ])
        ])

        configureCollectionView()
        loadBoards()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        checkForSignInFormDisplay()
    }

    // MARK: - data

    func configureCollectionView() {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self,
                                                 action: #selector(self.loadBoards),
                                                 for: .valueChanged)

        var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
        config.headerMode = .supplementary
        config.footerMode = .supplementary
        config.trailingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
            let board = self?.board(for: indexPath)

            let isFavorite = board?.attributes.favoritedAt != nil
            let title = isFavorite ? "Unfavorite" : "Favorite"
            let toggleFavoriteAction = UIContextualAction(style: .normal, title: title) {
                _, _, completion in
                guard let self = self,
                      let board = board else {
                    completion(false)
                    return
                }

                self.toggleFavorite(board, completion: completion)
            }

            return UISwipeActionsConfiguration(actions: [toggleFavoriteAction])
        }

        let layout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView.collectionViewLayout = layout
        collectionView.allowsFocus = true

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Board> {
            (cell, _, board) in

            var content = cell.defaultContentConfiguration()

            content.text = board.attributes.name ?? Board.defaultName
            content.image = board.attributes.icon?.image ?? Icon.defaultBoardImage
            content.imageProperties.tintColor = board.attributes.colorTheme?.uiColor ?? ColorTheme.defaultUIColor

            cell.contentConfiguration = content
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: UICollectionView.elementKindSectionHeader) {
            (supplementaryView, _, indexPath) in
                let boardGroup = self.boardGroups[indexPath.section]
                supplementaryView.label.text = boardGroup.section.rawValue
        }
        let footerRegistration = UICollectionView.SupplementaryRegistration<ButtonSupplementaryView>(
            elementKind: UICollectionView.elementKindSectionFooter) {
            (supplementaryView, _, indexPath) in
                let button = supplementaryView.button

                if indexPath.section == self.boardGroups.count - 1 {
                    supplementaryView.addButton()
                    button.isHidden = false
                    button.configuration = .plain()
                    button.configuration?.title = "Add Board"
                    button.configuration?.image = UIImage(systemName: "plus")
                    button.configuration?.imagePadding = 5
                    button.addTarget(self,
                                     action: #selector(self.createBoard(_:)),
                                     for: .touchUpInside)
                } else {
                    supplementaryView.removeButton()
                }
        }

        dataSource = UICollectionViewDiffableDataSource<BoardGroup.Section, Board>(
            collectionView: collectionView) {
            (collectionView, indexPath, board) in

            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: board)
        }
        dataSource.supplementaryViewProvider = { (collectionView, kind, index) in
            if kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
            } else {
                return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: index)
            }
        }

        collectionView.dataSource = dataSource
    }

    @IBAction func loadBoards() {
        boardStore.all { [weak self] (result) in
            guard let self = self else { return }

            collectionView.refreshControl?.endRefreshing()
            switch result {
            case let .success(boards):
                self.boards = boards
                self.updateBoardGroups()
            case let .failure(error):
                print("Error loading boards: \(error)")
            }
        }
    }

    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<BoardGroup.Section, Board>()

        boardGroups.forEach { (group) in
            snapshot.appendSections([group.section])
            snapshot.appendItems(group.boards)
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - collection view delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let board = board(for: indexPath)
        goTo(board)
    }

    // MARK: - actions

    func showUserSettings() {
        performSegue(withIdentifier: "settings", sender: nil)
    }

    func showAboutPage() {
        UIApplication.shared.open(URL(string: "https://about.riverbed.app")!)
    }

    func showSourceCode() {
        UIApplication.shared.open(URL(string: "https://link.riverbed.app/source-ios")!)
    }

    func goTo(_ board: Board) {
        delegate?.didSelect(board: board)
        splitViewController?.show(.secondary)
    }

    func toggleFavorite(_ board: Board, completion: @escaping (Bool) -> Void) {
        let newFavoritedAt = board.attributes.favoritedAt == nil ? Date() : nil

        let updatedAttributes = Board.Attributes(name: board.attributes.name,
                                                 icon: board.attributes.icon,
                                                 colorTheme: board.attributes.colorTheme,
                                                 favoritedAt: newFavoritedAt,
                                                 options: board.attributes.options)
        boardStore.update(board, with: updatedAttributes) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.loadBoards()
                completion(true)
            case let .failure(error):
                print("Error toggling board favorite: \(String(describing: error))")
                let action = newFavoritedAt == nil ? "unfavoriting" : "favoriting"
                self.showAlert(withErrorMessage: "An error occurred while \(action) the board.")
                completion(false)
            }
        }
    }

    @objc func createBoard(_ sender: Any?) {
        boardStore.create { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case let .success(board):
                self.goTo(board)
                self.loadBoards()
            case let .failure(error):
                print("Error creating board: \(String(describing: error))")
                self.showAlert(withErrorMessage: "An error occurred while creating the board.")
            }
        }
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

    func checkForSignInFormDisplay() {
        if tokenSource.accessToken == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let signInVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: SignInViewController.self)) as? SignInViewController
            else { preconditionFailure("Expected a SignInViewController") }
            signInVC.delegate = self
            signInVC.tokenStore = tokenStore
            signInVC.userStore = userStore
            present(signInVC, animated: true)
        }
    }

    func signOut() {
        tokenSource.accessToken = nil
    }

    // MARK: - private helpers

    private func board(for indexPath: IndexPath) -> Board {
        boardGroups[indexPath.section].boards[indexPath.row]
    }

    // MARK: - app-specific delegates

    func didUpdate(board: Board) {
        loadBoards()
    }

    func didDelete(board: Board) {
        splitViewController?.show(.primary) // for views where it isn't always shown: iPhone and iPad portrait
        loadBoards()
    }

    func didReceive(tokenResponse: TokenStore.TokenResponse) {
        tokenSource.accessToken = tokenResponse.accessToken
        tokenSource.userId = String(tokenResponse.userId)
        loadBoards()
    }

    // MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "settings":
            guard let navigationVC = segue.destination as? UINavigationController else {
                preconditionFailure("Expected a UINavigationController")
            }
            guard let settingsVC = navigationVC.viewControllers.first as? UserSettingsViewController else {
                preconditionFailure("Expected a UserSettingsViewController")
            }
            settingsVC.tokenSource = tokenSource
            settingsVC.userStore = userStore
            settingsVC.boards = boards
        default:
            preconditionFailure("Unexpected segue identifier: \(String(describing: segue.identifier))")
        }
    }

}
