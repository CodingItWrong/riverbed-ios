import UIKit

class BoardViewController: UIViewController, BoardListDelegate {

    var board: Board? {
        didSet {
            navigationItem.title = board?.attributes.name
        }
    }

    func didSelect(board: Board) {
        // TODO: consider if we need to reload the Board from the server
        self.board = board
    }

}
