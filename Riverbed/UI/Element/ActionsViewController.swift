import UIKit

protocol ActionsDelegate: AnyObject {
    func didUpdate(_ action: [Element.Action])
}

class ActionsViewController: UITableViewController,
                             EditActionDelegate {

    weak var delegate: ActionsDelegate?

    var actions = [Element.Action]()
    var elements = [Element]()

    // MARK: - vc lifecycle

    override func viewWillAppear(_ animated: Bool) {
        tableView.isEditing = true // keep it editing
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        actions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let action = actions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "condition", for: indexPath)

        if let command = action.command,
           let fieldId = action.field,
           let field = elements.first(where: { $0.id == fieldId }) {
            cell.textLabel?.text = "\(command.label) \(field.attributes.name ?? "(unnamed field)")"
        } else {
            cell.textLabel?.text = "(not configured)"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "editAction", sender: cell)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            actions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            delegate?.didUpdate(actions)
        default:
            preconditionFailure("Unexpected editing style \(editingStyle)")
        }
    }

    // MARK: - actions

    @IBAction func addAction(_ sender: Any?) {
        let newAction = Element.Action()
        actions.append(newAction)
        let indexPath = IndexPath(row: actions.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        delegate?.didUpdate(actions)
    }

    // MARK: - app-specific delegates

    func didUpdate(_ condition: Condition) {
        tableView.reloadData()
        // may not need to do anything else since Condition is mutable
    }

    func didUpdate(_ action: Element.Action) {
        tableView.reloadData()
    }

    // MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        segue.destination.view.tintColor = view.tintColor

        switch segue.identifier {
        case "editAction":
            guard let cell = sender as? UITableViewCell else {
                preconditionFailure("Expected a UITableViewCell")
            }
            guard let indexPath = tableView.indexPath(for: cell) else {
                preconditionFailure("Could not find index path for cell")
            }
            let action = actions[indexPath.row]

            segue.destination.popoverPresentationController?.sourceView = cell
            guard let editConditionVC = segue.destination as? EditActionViewController else {
                preconditionFailure("Expected an EditActionViewController")
            }

            editConditionVC.action = action
            editConditionVC.elements = elements
            editConditionVC.delegate = self

        default:
            preconditionFailure("Unexpected segue \(String(describing: segue.identifier))")
        }
    }

}
