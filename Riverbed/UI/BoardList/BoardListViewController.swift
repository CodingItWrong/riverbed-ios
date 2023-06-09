import UIKit

protocol BoardListDelegate: AnyObject {
    func didSelect(board: Board)
}

class BoardListViewController: UITableViewController,
                               BoardDelegate {

    weak var delegate: BoardListDelegate?

    var boardStore: BoardStore!
    var boards = [Board]()

    var boardGroups = [BoardGroup]()

    func updateBoardGroups() {
        let temp = Dictionary(grouping: boards) { (board) in
            board.attributes.favoritedAt != nil
        }

        var boardGroups = [BoardGroup]()
        if let favorites = temp[true] {
            boardGroups.append(
                BoardGroup(name: "Favorites",
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
                BoardGroup(name: "Other Boards",
                           boards: unfavorites.sorted {
                               guard let aName = $0.attributes.name,
                                     let bName = $1.attributes.name else {
                                   return false
                               }

                               return aName < bName
                           }))
        }
        self.boardGroups = boardGroups
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadBoards()
        self.refreshControl?.addTarget(self,
                                       action: #selector(self.loadBoards),
                                       for: .valueChanged)
    }

    @objc func loadBoards() {
        boardStore.all { (result) in
            self.refreshControl?.endRefreshing()
            switch result {
            case let .success(boards):
                self.boards = boards
                self.updateBoardGroups()
            case let .failure(error):
                print("Error loading boards: \(error)")
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        boardGroups.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        boardGroups[section].boards.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        boardGroups[section].name
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: BoardCell.self),
            for: indexPath) as? BoardCell else { preconditionFailure("Unexpected cell class") }
        let board = board(for: indexPath)
        cell.board = board
        return cell
    }

    func goTo(_ board: Board) {
        updateTint(for: board)
        delegate?.didSelect(board: board)
        splitViewController?.show(.secondary)

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let board = board(for: indexPath)
        goTo(board)
    }

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let board = board(for: indexPath)

        let isFavorite = board.attributes.favoritedAt != nil
        let title = isFavorite ? "Unfavorite" : "Favorite"
        let toggleFavoriteAction = UIContextualAction(style: .normal, title: title) {
            _, _, _ in
            self.toggleFavorite(board)
        }

        return UISwipeActionsConfiguration(actions: [toggleFavoriteAction])
    }

    private func board(for indexPath: IndexPath) -> Board {
        boardGroups[indexPath.section].boards[indexPath.row]
    }

    func toggleFavorite(_ board: Board) {
        let newFavoritedAt = board.attributes.favoritedAt == nil ? Date() : nil

        let updatedAttributes = Board.Attributes(name: board.attributes.name,
                                                 icon: board.attributes.icon,
                                                 colorTheme: board.attributes.colorTheme,
                                                 favoritedAt: newFavoritedAt)
        boardStore.update(board, with: updatedAttributes) { [weak self] (result) in
            switch result {
            case .success:
                self?.loadBoards()
            case let .failure(error):
                print("Error toggling board favorite: \(String(describing: error))")
            }
        }
    }

    @IBAction func createBoard() {
        boardStore.create { [weak self] (result) in
            switch result {
            case let .success(board):
                self?.goTo(board)
                self?.loadBoards()
            case let .failure(error):
                print("Error creating board: \(String(describing: error))")
            }
        }
    }

    class BoardGroup {
        var name: String
        var boards: [Board]

        init(name: String, boards: [Board]) {
            self.name = name
            self.boards = boards
        }
    }

    func updateTint(for board: Board) {
        print("BoardViewController.updateTint")
        let tintColor = board.attributes.colorTheme?.uiColor ?? ColorTheme.defaultUIColor

        // iPhone: affects all navigation bar elements (maybe because it's one navigation bar that's shared
        navigationController?.navigationBar.tintColor = tintColor
    }

    // MARK: - app-specific delegates

    func didUpdate(board: Board) {
        updateTint(for: board)
        loadBoards()
    }

    func didDelete(board: Board) {
        splitViewController?.show(.primary) // for views where it isn't always shown: iPhone and iPad portrait
        loadBoards()
    }

}
