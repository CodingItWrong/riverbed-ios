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

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            print("delete condition")
        default:
            preconditionFailure("Unexpected editing style \(editingStyle)")
        }
    }

    // MARK: - actions

    @IBAction func addCondition(_ sender: Any?) {
        print("add condition")
    }

}
