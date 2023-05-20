import UIKit

class CardViewController: UITableViewController {

    var elements = [Element]()
    var card: Card?

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = elements[indexPath.row]
        let dataType = element.attributes.dataType ?? .text

        // TODO: try again to extract out the specifying of a type to a variable
        var cell: ElementCell
        switch dataType {
        case .choice:
            guard let choiceCell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ChoiceElementCell.self),
                for: indexPath) as? ElementCell
            else { preconditionFailure("Expected a DateElementCell") }
            cell = choiceCell
        case .date:
            guard let dateCell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: DateElementCell.self),
                for: indexPath) as? ElementCell
            else { preconditionFailure("Expected a DateElementCell") }
            cell = dateCell
        case .dateTime:
            guard let dateTimeCell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: DateElementCell.self),
                for: indexPath) as? ElementCell
            else { preconditionFailure("Expected a DateElementCell") }
            cell = dateTimeCell
        case .geolocation:
            guard let geolocationCell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: GeolocationElementCell.self),
                for: indexPath) as? ElementCell
            else { preconditionFailure("Expected a GeolocationElementCell") }
            cell = geolocationCell
        case .number:
            guard let numberCell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: TextElementCell.self),
                for: indexPath) as? ElementCell
            else { preconditionFailure("Expected a TextElementCell") }
            cell = numberCell
        case .text:
            guard let textCell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: TextElementCell.self),
                for: indexPath) as? TextElementCell
            else { preconditionFailure("Expected a TextElementCell") }
            cell = textCell
        }
        if let card = card {
            cell.update(for: element, and: card)
        }
        return cell
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

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            elements.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}
