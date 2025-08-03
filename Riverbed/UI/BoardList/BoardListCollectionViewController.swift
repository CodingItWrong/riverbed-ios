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

        let unfavorites = temp[false] ?? []
        boardGroups.append(
            BoardGroup(section: .other,
                       boards: unfavorites.sorted {
                           guard let aName = $0.attributes.name,
                                 let bName = $1.attributes.name else {
                               return false
                           }

                           return aName < bName
                       }))
        self.boardGroups = boardGroups
        self.updateSnapshot()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isPlatformMac() {
            fixTitleColors()
        }
        
        guard let menuButton = navigationItem.rightBarButtonItem else {
            preconditionFailure("Expected a right bar button item")
        }
        menuButton.menu = UIMenu(children: [
            UIMenu(options: .displayInline, children: [
                UIAction(title: "User settings", image: UIImage(systemName: "gear")) { _ in
                    self.showUserSettings()
                },
                UIAction(title: "Sign out", image: UIImage(systemName: "rectangle.portrait.and.arrow.right")) { _ in
                    self.signOut()
                    self.checkForSignInFormDisplay()
                }
            ]),
            UIMenu(title: "More info", children: [
                UIAction(title: "About", image: UIImage(systemName: "info.circle")) { _ in
                    self.showAboutPage()
                },
                UIAction(title: "Source code", image: UIImage(systemName: "curlybraces")) { _ in
                    self.showSourceCode()
                }
            ]),
            UIMenu(title: "Danger Zone", children: [
                UIAction(title: "Delete my account",
                         image: UIImage(systemName: "person.crop.circle.badge.xmark"),
                         attributes: [.destructive]) { _ in
                    self.confirmDeleteAccount()
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if !isPlatformMac() {
            fixTitleColors()
            collectionView.reloadData()
        }
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

            let tintColor = board.attributes.colorTheme?.uiColor ?? ColorTheme.defaultUIColor
            if isPlatformMac() {
                // duplicate to work around OS 26 bug
                content.imageProperties.tintColor = UIColor(cgColor: tintColor.cgColor)
            } else {
                content.imageProperties.tintColor = tintColor
            }

            cell.contentConfiguration = content
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: UICollectionView.elementKindSectionHeader) {
            (supplementaryView, _, indexPath) in
                let boardGroup = self.boardGroups[indexPath.section]
                supplementaryView.label.text = boardGroup.section.rawValue
                
                // work around iPadOS 26 issue
                if !isPlatformMac() {
                    supplementaryView.label.textColor = UIColor(cgColor: UIColor.secondaryLabel.cgColor)
                }
        }
        let footerRegistration = UICollectionView.SupplementaryRegistration<ButtonSupplementaryView>(
            elementKind: UICollectionView.elementKindSectionFooter) {
            (supplementaryView, _, indexPath) in
                let button = supplementaryView.button

                if indexPath.section == self.boardGroups.count - 1 {
                    supplementaryView.addButton()
                    button.isHidden = false
                    button.configuration = .plain()
                    button.configuration?.title = "New Board"
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
        print("LOADING BOARDS")
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

    override func collectionView(_ collectionView: UICollectionView,
                                 contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                                 point: CGPoint) -> UIContextMenuConfiguration? {
        let indexPath = indexPaths.first
        guard let indexPath = indexPath else { return nil }
        let board = board(for: indexPath)

        return UIContextMenuConfiguration(identifier: board.id as NSCopying, previewProvider: nil) { _ in
            let isFavorite = board.attributes.favoritedAt != nil
            let title = isFavorite ? "Unfavorite" : "Favorite"
            let toggleFavoriteAction = UIAction(title: title) { [weak self] _ in
                self?.toggleFavorite(board)
            }

            return UIMenu(children: [toggleFavoriteAction])
        }

    }

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

    func confirmDeleteAccount() {
        let message = "Are you sure you want to delete your account? " +
                      "All boards and cards will be immediately deleted and there will be NO way to recover them."

        let alert = UIAlertController(title: "WARNING: Delete your account?",
                                      message: message,
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Keep my account", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        let deleteAction = UIAlertAction(title: "Delete my account", style: .destructive) { _ in
            self.deleteAccount()
        }
        alert.addAction(deleteAction)

        alert.preferredAction = cancelAction
        present(alert, animated: true)
    }

    func deleteAccount() {
        guard let userId = tokenSource.userId else { return }

        userStore.find(userId) { [weak self] (result) in
            guard let self = self else { return }

            switch result {
            case let .success(user):
                self.userStore.delete(user) { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .success:
                        let alert = UIAlertController(title: "Account deleted",
                                                      message: "Your account has been successfully deleted.",
                                                      preferredStyle: .alert)

                        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                            guard let self = self else { return }

                            self.signOut()
                            self.checkForSignInFormDisplay()
                        }
                        alert.addAction(okAction)
                        alert.preferredAction = okAction
                        present(alert, animated: true)

                    case let .failure(error):
                        print("Error deleting account: \(String(describing: error))")
                        let message = "An error occurred while deleting your account." +
                                      " Please email help@riverbed.app and we will ensure your account is deleted."
                        self.showAlert(withErrorMessage: message)
                    }
                }
            case let .failure(error):
                print("Error loading user: \(String(describing: error))")
            }
        }
    }

    func goTo(_ board: Board) {
        delegate?.didSelect(board: board)
        splitViewController?.show(.secondary)
    }

    // TODO: need @escaping?
    func toggleFavorite(_ board: Board, completion: ((Bool) -> Void)? = nil) {
        let newFavoritedAt = board.attributes.favoritedAt == nil ? Date() : nil

        let updatedAttributes = Board.Attributes(name: board.attributes.name,
                                                 iconName: board.attributes.iconName,
                                                 colorTheme: board.attributes.colorTheme,
                                                 favoritedAt: newFavoritedAt,
                                                 options: board.attributes.options)
        boardStore.update(board, with: updatedAttributes) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.loadBoards()
                completion?(true)
            case let .failure(error):
                print("Error toggling board favorite: \(String(describing: error))")
                let action = newFavoritedAt == nil ? "unfavoriting" : "favoriting"
                self.showAlert(withErrorMessage: "An error occurred while \(action) the board.")
                completion?(false)
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
    
    private func fixTitleColors() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(cgColor: UIColor.label.cgColor)]
        navigationController?.navigationBar.standardAppearance = appearance
    }

    // MARK: - app-specific delegates

    func didUpdate(board: Board) {
        loadBoards()
    }

    func didDelete(board: Board) {
        splitViewController?.show(.primary) // for views where it isn't always shown: iPhone and iPad portrait
        loadBoards()
    }

    func didReceive(tokenResponse: TokenResponse) {
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
