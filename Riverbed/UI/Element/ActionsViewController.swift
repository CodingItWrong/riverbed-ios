import UIKit

protocol ActionsDelegate: AnyObject {
    func didUpdate(_ actions: [Action])
}

class ActionsViewController: UITableViewController,
                             EditActionDelegate {

    weak var delegate: ActionsDelegate?

    var actions = [Action]()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "action", for: indexPath)

        if let command = action.command,
           let fieldId = action.field,
           let field = elements.first(where: { $0.id == fieldId }) {

            let defaultString = "(empty)"
            let valueLabel = {
                switch command {
                case .addDays:
                    if let specificValue = action.specificValue,
                       case let .string(numDays) = specificValue {
                        return numDays
                    } else {
                        return defaultString
                    }
                case .setValue:
                    guard let value = action.value else { return defaultString }
                    switch value {
                    case .specificValue:
                        let valueString = {
                            if let specificValue = action.specificValue {
                                return field.formatString(from: specificValue)
                            } else {
                                return nil
                            }
                        }()
                        return valueString ?? defaultString
                    default:
                        return value.label
                    }
                }
            }()

            cell.textLabel?.text =
            "\(command.label) \(field.attributes.name ?? "(unnamed field)") \(valueLabel)"
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
        let newAction = Action()
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

    func didUpdate(_ action: Action) {
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
