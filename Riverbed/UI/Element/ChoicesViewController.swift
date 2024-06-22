import UIKit

protocol ChoicesDelegate: AnyObject {
    func didUpdate(choices: [Element.Choice])
}

class ChoicesViewController: UITableViewController, FormCellDelegate {

    weak var delegate: ChoicesDelegate?

    var choices = [Element.Choice]()

    // MARK: - vc lifecycle

    override func viewWillAppear(_ animated: Bool) {
        tableView.isEditing = true // keep it editing
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        choices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let choice = choices[indexPath.row]
        guard let cell = tableView.dequeueOrRegisterReusableCell(
            withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell else {
            preconditionFailure("Expected a TextFieldCell")
        }

        cell.label.removeFromSuperview()
        cell.textField.text = choice.label
        cell.delegate = self

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        if sourceIndexPath == destinationIndexPath {
            return
        }

        // move in UI
        let movedItem = choices[sourceIndexPath.row]
        choices.remove(at: sourceIndexPath.row)
        choices.insert(movedItem, at: destinationIndexPath.row)

        // persist to server
        // note that the order of the choices in the array *is* the display order
        delegate?.didUpdate(choices: choices)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            choices.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            delegate?.didUpdate(choices: choices)
        default:
            preconditionFailure("Unexpected editing style \(editingStyle)")
        }
    }

    // MARK: - actions

    @IBAction func addChoice(_ sender: Any?) {
        let newChoice = Element.Choice()
        choices.append(newChoice)
        let indexPath = IndexPath(row: choices.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        delegate?.didUpdate(choices: choices)
    }

    // MARK: - app-specific delegates

    func didPressButton(inFormCell formCell: UITableViewCell) {
        preconditionFailure("Unexpected call to didPressButton(inFormCell:)")
    }

    func valueDidChange(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else {
            preconditionFailure("Could not find indexPath for cell \(String(describing: formCell))")
        }
        valueDidChange(inFormCell: formCell, at: indexPath)
    }
    
    func valueDidChange(inFormCell formCell: UITableViewCell, at indexPath: IndexPath) {
        guard let textFieldCell = formCell as? TextFieldCell else {
            preconditionFailure("Expected a TextFieldCell")
        }
        let choice = choices[indexPath.row]
        choice.label = textFieldCell.textField.text
        delegate?.didUpdate(choices: choices)
    }

}
