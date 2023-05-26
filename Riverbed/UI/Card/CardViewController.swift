import UIKit

class CardViewController: UITableViewController {

    var cardStore: CardStore!

    var elements = [Element]()
    var card: Card?

    var sortedElements: [Element] {
        elements.sorted(by: Element.areInIncreasingOrder(lhs:rhs:))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = sortedElements[indexPath.row]
        let cellType = cellType(for: element)
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: cellType),
            for: indexPath) as? ElementCell
        else { preconditionFailure("Expected a \(String(describing: cellType))") }
        if let card = card {
            cell.update(for: element, and: card)
        }
        return cell
    }

    private func cellType(for element: Element) -> UITableViewCell.Type {
        switch element.attributes.elementType {
        case .button: return ButtonElementCell.self
        case .buttonMenu: return ButtonMenuElementCell.self
        case .field:
            switch element.attributes.dataType {
            case .choice: return ChoiceElementCell.self
            case .date: return DateElementCell.self
            case .dateTime: return DateElementCell.self
            case .geolocation: return GeolocationElementCell.self
            case .number: return TextElementCell.self
            case .text: return TextElementCell.self
            case .none: return TextElementCell.self
            }
        }
    }

    @IBAction func toggleEditing(_ sender: UIButton) {
        // TODO: voiceover
        if isEditing {
            setEditing(false, animated: true)
            sender.setImage(UIImage(systemName: "wrench"), for: .normal)
        } else {
            setEditing(true, animated: true)
            sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
        }
    }

    @IBAction func deleteCard(_ sender: UIButton) {
        guard let card = card else { return }

        let alert = UIAlertController(title: "Delete?",
                                      message: "Are you sure you want to delete this todo?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Delete",
                                      style: .destructive) {[weak self] _ in
            self?.cardStore.delete(card) { [weak self] (result) in
                switch result {
                case .success:
                    self?.dismiss(animated: true)
                case let .failure(error):
                    print("Error deleting card: \(String(describing: error))")
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        if sourceIndexPath == destinationIndexPath {
            return
        }

        // TODO: need to persist the new order to the server and resort from it
        let movedItem = elements[sourceIndexPath.row]
        elements.remove(at: sourceIndexPath.row)
        elements.insert(movedItem, at: destinationIndexPath.row)
    }

    override func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        } else {
            return .none // disable swipe-to-delete when not in editing mode
        }
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            elements.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}
