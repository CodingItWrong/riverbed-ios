import UIKit

protocol ButtonMenuItemsDelegate: AnyObject {
    func didUpdate(items: [Element.Item])
}

class ButtonMenuItemsViewController: UITableViewController,
                                     EditButtonMenuItemDelegate {

    weak var delegate: ButtonMenuItemsDelegate?

    var items = [Element.Item]()
    var elements = [Element]()

    // MARK: - vc lifecycle

    override func viewWillAppear(_ animated: Bool) {
        tableView.isEditing = true // keep it editing
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
        cell.textLabel?.text = item.name // TODO: see if it's really non-optional when create a new one
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "editItem", sender: cell)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            delegate?.didUpdate(items: items)
        default:
            preconditionFailure("Unexpected editing style \(editingStyle)")
        }
    }

    // MARK: - actions

    @IBAction func addItem(_ sender: Any?) {
        let newItem = Element.Item()
        items.append(newItem)
        let indexPath = IndexPath(row: items.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        delegate?.didUpdate(items: items)
    }

    // MARK: - app-specific delegates

    func didUpdate(item: Element.Item, at index: Int) {
        // actually don't need to save anything as we update the mutable item
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        delegate?.didUpdate(items: items)
    }

    // MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        segue.destination.view.tintColor = view.tintColor

        switch segue.identifier {
        case "editItem":
            guard let cell = sender as? UITableViewCell else {
                preconditionFailure("Expected a UITableViewCell")
            }
            guard let indexPath = tableView.indexPath(for: cell) else {
                preconditionFailure("Could not find index path for cell")
            }
            let item = items[indexPath.row]

            guard let editItemVC = segue.destination as? EditButtonMenuItemViewController else {
                preconditionFailure("Expected an EditButtonMenuItemViewController")
            }

            editItemVC.item = item
            editItemVC.index = indexPath.row
            editItemVC.elements = elements
            editItemVC.delegate = self

        default:
            preconditionFailure("Unexpected segue \(String(describing: segue.identifier))")
        }
    }

}
