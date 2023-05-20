import UIKit

class CardViewController: UITableViewController {

    var elements = [Element]()
    var card: Card?

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ElementTableCell
        else { preconditionFailure("Expected ElementTableCell") }

        let element = elements[indexPath.row]
        cell.elementLabel.text = element.attributes.name

        let value = card?.attributes.fieldValues[element.id]
        switch value {
        case let .string(stringValue):
            cell.valueTextField.text = stringValue
        case .dictionary:
            cell.valueTextField.text = "(TEMP: dictionary)"
        case .none:
            cell.valueTextField.text = ""
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
