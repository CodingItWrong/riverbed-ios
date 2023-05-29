import UIKit

class BoardCell: UITableViewCell {

    @IBOutlet private var boardIcon: UIImageView!
    @IBOutlet private var boardNameLabel: UILabel!

    var board: Board! {
        didSet { updateUIForBoard() }
    }

    func updateUIForBoard() {
        boardNameLabel.text = board.attributes.name
        boardIcon.image = board.attributes.icon?.image ?? Icon.defaultBoardImage
        boardIcon.tintColor = board.attributes.colorTheme?.uiColor ?? ColorTheme.defaultUIColor
    }

}
