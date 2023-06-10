import UIKit

protocol EditColumnViewControllerDelegate: AnyObject {
    func didUpdate(_ column: Column)
}

class EditColumnViewController: UITableViewController,
                                FormCellDelegate {

    enum Row: CaseIterable {
        case name
        case sortOrder
        case grouping
        case summary

        var label: String {
            switch self {
            case .name: return "Column Name"
            case .sortOrder: return "Sort Order"
            case .grouping: return "Grouping"
            case .summary: return "Summary"
            }
        }
    }

    var attributes: Column.Attributes!
    var column: Column! {
        didSet {
            attributes = column.attributes
        }
    }
    var elements: [Element] = []
    var fields: [Element] {
        elements.filter { $0.attributes.elementType == .field }
    }

    var columnStore: ColumnStore!
    weak var delegate: EditColumnViewControllerDelegate?

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

        case .sortOrder:
            let cell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: SortByCell.self))
            guard let sortByCell = cell as? SortByCell
            else { preconditionFailure("Expected a SortByCell") }

            sortByCell.label.text = rowEnum.label
            sortByCell.delegate = self
            sortByCell.configure(column.attributes.cardSortOrder, fields: fields)
            return sortByCell

        case .grouping:
            guard let sortByCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: SortByCell.self)) as? SortByCell
            else { preconditionFailure("Expected a SortByCell") }

            sortByCell.label.text = rowEnum.label
            sortByCell.delegate = self
            sortByCell.configure(column.attributes.cardGrouping, fields: fields)
            return sortByCell

        case .summary:
            guard let summaryCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: SummaryCell.self)) as? SummaryCell
            else { preconditionFailure("Expected a SummaryCell") }

            summaryCell.label.text = rowEnum.label
            summaryCell.delegate = self
            summaryCell.configure(column.attributes.summary, fields: fields)
            return summaryCell

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

        case .sortOrder:
            guard let sortByCell = formCell as? SortByCell
            else { preconditionFailure("Expected a SortByCell") }
            if attributes.cardSortOrder == nil {
                attributes.cardSortOrder = Column.SortOrder()
            }
            attributes.cardSortOrder?.field = sortByCell.selectedField?.id
            attributes.cardSortOrder?.direction = sortByCell.selectedDirection

        case .grouping:
            guard let sortByCell = formCell as? SortByCell
            else { preconditionFailure("Expected a SortByCell") }
            if attributes.cardGrouping == nil {
                attributes.cardGrouping = Column.SortOrder()
            }
            attributes.cardGrouping?.field = sortByCell.selectedField?.id
            attributes.cardGrouping?.direction = sortByCell.selectedDirection

        case .summary:
            guard let summaryCell = formCell as? SummaryCell
            else { preconditionFailure("Expected a SummaryCell") }
            if attributes.summary == nil {
                attributes.summary = Column.Summary()
            }
            attributes.summary?.function = summaryCell.selectedFunction
            attributes.summary?.field = summaryCell.selectedField?.id
        }
    }

}
