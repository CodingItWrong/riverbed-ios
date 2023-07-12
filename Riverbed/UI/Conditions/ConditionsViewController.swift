import UIKit

protocol ConditionsDelegate: AnyObject {
    func didUpdate(_ conditions: [Condition])
}

class ConditionsViewController: UITableViewController, EditConditionDelegate {

    weak var delegate: ConditionsDelegate?

    var conditions = [Condition]()
    var elements = [Element]()

    // MARK: - vc lifecycle

    override func viewWillAppear(_ animated: Bool) {
        tableView.isEditing = true // keep it editing
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conditions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let condition = conditions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "condition", for: indexPath)

        if let query = condition.query,
           let fieldId = condition.field,
           let field = elements.first(where: { $0.id == fieldId }) {

            let basicDescription = "\(field.attributes.name ?? "(unnamed field") \(query.label)"
            if condition.query?.showConcreteValueField == true {
                let valueString = {
                    if let value = condition.options?.value {
                        return field.formatString(from: value)
                    } else {
                        return nil
                    }
                }()
                cell.textLabel?.text = "\(basicDescription) \(valueString ?? "(no value)")"
            } else {
                cell.textLabel?.text = basicDescription
            }
        } else {
            cell.textLabel?.text = "(not configured)"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "editCondition", sender: cell)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            conditions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            delegate?.didUpdate(conditions)
        default:
            preconditionFailure("Unexpected editing style \(editingStyle)")
        }
    }

    // MARK: - actions

    @IBAction func addCondition(_ sender: Any?) {
        let newCondition = Condition()
        conditions.append(newCondition)
        let indexPath = IndexPath(row: conditions.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        delegate?.didUpdate(conditions)
    }

    // MARK: - app-specific delegates

    func didUpdate(_ condition: Condition) {
        tableView.reloadData()
        // may not need to do anything else since Condition is mutable
    }

    // MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        segue.destination.view.tintColor = view.tintColor

        switch segue.identifier {
        case "editCondition":
            guard let cell = sender as? UITableViewCell else {
                preconditionFailure("Expected a UITableViewCell")
            }
            guard let indexPath = tableView.indexPath(for: cell) else {
                preconditionFailure("Could not find index path for cell")
            }
            let condition = conditions[indexPath.row]

            segue.destination.popoverPresentationController?.sourceView = cell
            guard let editConditionVC = segue.destination as? EditConditionViewController else {
                preconditionFailure("Expected an EditConditionViewController")
            }

            editConditionVC.condition = condition
            editConditionVC.elements = elements
            editConditionVC.delegate = self

        default:
            preconditionFailure("Unexpected segue \(String(describing: segue.identifier))")
        }
    }

}
