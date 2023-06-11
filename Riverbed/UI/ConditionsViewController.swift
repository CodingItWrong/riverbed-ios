import UIKit

class ConditionsViewController: UITableViewController {

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
            cell.textLabel?.text = "\(field.attributes.name ?? "(unnamed field") \(query.label)"
            // TODO: show options
        } else {
            cell.textLabel?.text = "(not configured)"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let condition = conditions[indexPath.row]
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
    }

    // MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "editCondition":
            guard let cell = sender as? UITableViewCell else {
                preconditionFailure("Expected a UITableViewCell")
            }
            segue.destination.popoverPresentationController?.sourceView = cell
            print("edit condition")

        default:
            preconditionFailure("Unexpected segue \(segue.identifier)")
        }
    }

}
