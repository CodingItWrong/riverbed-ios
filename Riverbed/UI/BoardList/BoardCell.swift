import UIKit

protocol BoardCellDelegate: AnyObject {
    func toggleFavorite(_ board: Board)
}

class BoardCell: UITableViewCell {

    weak var delegate: BoardCellDelegate?

    @IBOutlet private var boardNameLabel: UILabel!
    @IBOutlet private var favoriteButton: UIButton!

    var board: Board! {
        didSet { updateUIForBoard() }
    }

    var isFavorite: Bool {
        board.attributes.favoritedAt != nil
    }

    func updateUIForBoard() {
        boardNameLabel.text = board.attributes.name

        if isFavorite {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }

    @IBAction func toggleFavorite(_ sender: UIButton) {
        delegate?.toggleFavorite(board)
    }

}
