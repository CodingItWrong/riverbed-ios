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

        switch dataType {
//        case .choice:
//            guard let cell = tableView.dequeueReusableCell(
//                withIdentifier: String(describing: ChoiceElementCell.self),
//                for: indexPath) as? ChoiceElementCell else {
//                preconditionFailure("Expected a DateElementCell")
//            }
//            return cell
        case .date:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DateElementCell.self),
                                                         for: indexPath) as? DateElementCell else {
                preconditionFailure("Expected a DateElementCell")
            }
            cell.valueDatePicker.datePickerMode = .date
            if let card = card {
                cell.update(for: element, and: card)
            }
            return cell
        case .dateTime:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: DateElementCell.self),
                for: indexPath) as? DateElementCell else {
                preconditionFailure("Expected a DateElementCell")
            }
            cell.valueDatePicker.datePickerMode = .dateAndTime
            if let card = card {
                cell.update(for: element, and: card)
            }
            return cell
        case .number:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TextElementCell.self),
                                                               for: indexPath) as? TextElementCell else {
                preconditionFailure("Expected a TextElementCell")
            }
            if let card = card {
                cell.update(for: element, and: card)
            }
            return cell
        default: // TODO: cover all cases explicitly
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TextElementCell.self),
                                                               for: indexPath) as? TextElementCell else {
                preconditionFailure("Expected a TextElementCell")
            }
            if let card = card {
                cell.update(for: element, and: card)
            }
            return cell
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

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            elements.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}
