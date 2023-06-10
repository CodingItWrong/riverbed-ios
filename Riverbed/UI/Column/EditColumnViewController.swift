import UIKit

protocol EditColumnViewControllerDelegate: AnyObject {
    func didUpdate(_ column: Column)
}

class EditColumnViewController: UITableViewController,
                                FormCellDelegate {

    enum Row: CaseIterable {
        case name

        var label: String {
            switch self {
            case .name: return "Column Name"
            }
        }
    }

    var attributes: Column.Attributes!
    var column: Column! {
        didSet {
            attributes = column.attributes
        }
    }

    var columnStore: ColumnStore!
    var delegate: EditColumnViewControllerDelegate?

    // MARK: - view controller lifecycle

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let column = column else { return }
        columnStore.update(column, with: attributes) { [weak self] (result) in
            switch result {
            case .success:
                print("SAVED COLUMN \(column.id)")
                self?.delegate?.didUpdate(column)
            case let .failure(error):
                print("Error saving column: \(String(describing: error))")
            }
        }
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

            textFieldCell.label.text = rowEnum.label
            textFieldCell.delegate = self
            textFieldCell.textField.text = attributes.name
            return textFieldCell
        }
    }

    // MARK: app-specific delegates

    func valueDidChange(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else { return }
        let rowEnum = Row.allCases[indexPath.row]

        switch rowEnum {
        case .name:
            guard let textFieldCell = formCell as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }
            attributes.name = textFieldCell.textField.text
        }
    }

}
