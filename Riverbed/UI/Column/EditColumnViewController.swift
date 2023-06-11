import UIKit

protocol EditColumnViewControllerDelegate: AnyObject {
    func didUpdate(_ column: Column)
}

class EditColumnViewController: UITableViewController,
                                FormCellDelegate {

    enum Row: CaseIterable {
        case name
        case cardsToInclude
        case sortOrder
        case grouping
        case summary

        var label: String {
            switch self {
            case .name: return "Column Name"
            case .cardsToInclude: return "Cards to Include"
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
        // note that this runs both when the modal is dismissed and when pushing a VC on the navigation stack
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

        case .cardsToInclude:
            guard let buttonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: ButtonCell.self)) as? ButtonCell
            else { preconditionFailure("Expected a ButtonCell") }

            buttonCell.delegate = self
            buttonCell.label.text = rowEnum.label
            let conditionCount = attributes.cardInclusionConditions?.count ?? 0
            let buttonTitle = conditionCount > 0 ? "\(conditionCount) conditions" : "All cards"
            buttonCell.button.setTitle(buttonTitle, for: .normal)
            return buttonCell

        case .sortOrder:
            guard let sortByCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: SortByCell.self)) as? SortByCell
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

    func didPressButton(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else { return }
        let rowEnum = Row.allCases[indexPath.row]

        switch rowEnum {
        case .cardsToInclude:
            performSegue(withIdentifier: "cardsToInclude", sender: self)

        default:
            preconditionFailure("Unexpected form cell \(rowEnum)")
        }
    }

    func valueDidChange(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else { return }
        let rowEnum = Row.allCases[indexPath.row]

        switch rowEnum {
        case .name:
            guard let textFieldCell = formCell as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }
            attributes.name = textFieldCell.textField.text

        case .cardsToInclude:
            preconditionFailure("Unexpected form cell cardsToInclude")

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

    // MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "cardsToInclude":
            guard let conditionsVC = segue.destination as? ConditionsViewController else {
                preconditionFailure("Expected a ConditionsViewController")
            }
            conditionsVC.conditions = column.attributes.cardInclusionConditions ?? []
            conditionsVC.elements = elements
        default:
            preconditionFailure("Unexpected segue \(segue.identifier)")
        }
    }

}
