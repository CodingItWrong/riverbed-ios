import UIKit

class BoardViewController: UIViewController, BoardListDelegate, UICollectionViewDataSource {

    @IBOutlet var columnsCollectionView: UICollectionView!

    var columnStore: ColumnStore!
    var columns = [Column]()

    var board: Board? {
        didSet { updateForBoard() }
    }

    func didSelect(board: Board) {
        // TODO: consider if we need to reload the Board from the server
        self.board = board
    }

    func updateForBoard() {
        guard let board = board else { return }

        navigationItem.title = board.attributes.name
        columnStore.all(for: board) { (result) in
            switch result {
            case let .success(columns):
                self.columns = columns
                self.columnsCollectionView.reloadData()
            case let .failure(error):
                print("Error loading columns: \(error)")
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        columns.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = columnsCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ColumnCell.self),
            for: indexPath) as? ColumnCell else { preconditionFailure("Unexpected cell class") }
        let column = columns[indexPath.row]

        cell.title.text = column.attributes.name

        return cell
    }

}

class ColumnCell: UICollectionViewCell {
    @IBOutlet var title: UILabel!
}
