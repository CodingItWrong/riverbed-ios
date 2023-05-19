import UIKit

protocol BoardListDelegate: AnyObject {
    func didSelect(board: Board)
}

class BoardListViewController: UITableViewController {

    weak var delegate: BoardListDelegate?

    var boardStore: BoardStore!
    var boards = [Board]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadBoards()
    }

    func loadBoards() {
        boardStore.all { (result) in
            switch result {
            case let .success(boards):
                self.boards = boards
                self.tableView.reloadData()
            case let .failure(error):
                print("Error loading boards: \(error)")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        boards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: UITableViewCell.self),
            for: indexPath)
        let board = boards[indexPath.row]

        cell.textLabel?.text = board.attributes.name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let board = boards[indexPath.row]
        delegate?.didSelect(board: board)
        splitViewController?.show(.secondary)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
