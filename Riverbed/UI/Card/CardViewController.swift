import UIKit

class CardViewController: UITableViewController {

    var elements = [Element]()
    var card: Card?

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = elements[indexPath.row]
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
            sender.setImage(UIImage(systemName: "highlighter"), for: .normal)
        } else {
            setEditing(true, animated: true)
            sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
        }
    }

    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        if sourceIndexPath == destinationIndexPath {
            return
        }

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
