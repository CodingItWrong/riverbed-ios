import UIKit

protocol BoardListDelegate: AnyObject {
    func didSelect(board: Board)
}

class BoardListViewController: UITableViewController {

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
                           boards: unfavorites.sorted { $0.attributes.name < $1.attributes.name }))
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

        cell.boardNameLabel.text = board.attributes.name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let board = board(for: indexPath)
        delegate?.didSelect(board: board)
        splitViewController?.show(.secondary)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func board(for indexPath: IndexPath) -> Board {
        boardGroups[indexPath.section].boards[indexPath.row]
    }

    class BoardGroup {
        var name: String
        var boards: [Board]

        init(name: String, boards: [Board]) {
            self.name = name
            self.boards = boards
        }
    }

}
