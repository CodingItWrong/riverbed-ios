import UIKit

protocol EditButtonMenuItemDelegate: AnyObject {
    func didUpdate(item: Element.Item, at index: Int)
}

class EditButtonMenuItemViewController: UITableViewController,
                                        ActionsDelegate,
                                        FormCellDelegate {

    enum Row: CaseIterable {
        case name
        case actions

        var label: String {
            switch self {
            case .name: return "Name"
            case .actions: return "Actions"
            }
        }
    }

    weak var delegate: EditButtonMenuItemDelegate?
    var item: Element.Item!
    var index = -1

    var elements = [Element]()
    var fields: [Element] {
        elements.filter { $0.attributes.elementType == .field }.inDisplayOrder
    }

    // MARK: - VC lifecycle

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let delegate = delegate else {
            preconditionFailure("Expected an EditActionDelegate")
        }

        delegate.didUpdate(item: item, at: index)
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowEnum = Row.allCases[indexPath.row]
        switch rowEnum {
        case .name:
            guard let textFieldCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }

            textFieldCell.textField.text = item.name
            textFieldCell.delegate = self
            return textFieldCell

        case .actions:
            guard let buttonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: ButtonCell.self)) as? ButtonCell
            else { preconditionFailure("Expected a ButtonCell") }

            buttonCell.delegate = self
            buttonCell.label.text = rowEnum.label
            let actionCount = item.actions?.count ?? 0

            let buttonTitle: String = {
                switch actionCount {
                case 0:
                    return "(none)"
                case 1:
                    return "\(actionCount) action"
                default:
                    return "\(actionCount) actions"
                }
            }()
            buttonCell.button.setTitle(buttonTitle, for: .normal)
            return buttonCell
        }
    }

    // MARK: - app-specific delegates

    func didPressButton(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else { return }

        let rowEnum = Row.allCases[indexPath.row]
        switch rowEnum {
        case .actions: performSegue(withIdentifier: "actions", sender: self)
        default: preconditionFailure("Unexpected row \(indexPath.row)")
        }
    }

    func valueDidChange(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else { return }
        let rowEnum = Row.allCases[indexPath.row]
        switch rowEnum {
        case .name:
            guard let textFieldCell = formCell as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }
            item.name = textFieldCell.textField.text ?? ""
        default:
            preconditionFailure("Unexpected valueDidChange for form cell \(indexPath)")
        }
    }

    func didUpdate(_ actions: [Action]) {
        item.actions = actions
        tableView.reloadData()
    }

    // MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "actions":
            guard let actionsVC = segue.destination as? ActionsViewController
            else { preconditionFailure("Expected an ActionsViewController ") }

            actionsVC.actions = item.actions ?? []
            actionsVC.elements = elements
            actionsVC.delegate = self
        default:
            preconditionFailure("Unexpected segue identifier \(segue.destination)")
        }
    }

}
