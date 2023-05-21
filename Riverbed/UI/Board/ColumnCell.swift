import UIKit

class ColumnCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var title: UILabel!
    @IBOutlet var tableView: UITableView!

    @IBOutlet weak var delegate: CardSummaryDelegate?

    var column: Column? {
        didSet {
            title.text = column?.attributes.name ?? ""
        }
    }
    var cards = [Card]() {
        didSet { tableView.reloadData() }
    }
    var elements = [Element]() {
        didSet { tableView.reloadData() }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cards.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if let cell = cell as? CardSummaryCell {
            let card = cards[indexPath.row]
            cell.configureData(card: card, elements: elements)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cards[indexPath.row]
        delegate?.cardSelected(card)
        tableView.deselectRow(at: indexPath, animated: true) // TODO: may not need if we change it to tap the card
    }
}
