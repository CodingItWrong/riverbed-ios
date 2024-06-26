import UIKit

protocol EditConditionDelegate: AnyObject {
    func didUpdate(condition: Condition)
}

class EditConditionViewController: UITableViewController,
                                   ElementCellDelegate,
                                   FormCellDelegate {

    enum Row: CaseIterable {
        case field
        case query
        case value

        static func cases(for condition: Condition) -> [Row] {
            if let query = condition.query,
               query.showConcreteValueField,
               condition.field != nil {
                return allCases
            } else {
                return [.field, .query]
            }
        }

        var label: String {
            switch self {
            case .field: return "Field"
            case .query: return "Query"
            case .value: return "Value"
            }
        }
    }

    weak var delegate: EditConditionDelegate?
    var condition: Condition!

    var elements = [Element]()
    var fields: [Element] {
        elements.filter { $0.attributes.elementType == .field }.inDisplayOrder
    }

    // MARK: - VC lifecycle

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let delegate = delegate else {
            preconditionFailure("Expected an EditConditionDelegate")
        }

        delegate.didUpdate(condition: condition)
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.cases(for: condition).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowEnum = Row.cases(for: condition)[indexPath.row]
        print("Configuring cell for row \(rowEnum.label)")
        switch rowEnum {
        case .field:
            guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }

            popUpButtonCell.label.text = rowEnum.label
            popUpButtonCell.delegate = self
            let selectedField = fields.first { $0.id == condition?.field }
            popUpButtonCell.configure(options: fieldOptions(selecting: selectedField))
            return popUpButtonCell

        case .query:
            guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }

            popUpButtonCell.label.text = rowEnum.label
            popUpButtonCell.delegate = self
            let options = Query.allCases.map { (query) in
                PopUpButtonCell.Option(title: query.label, value: query, isSelected: condition?.query == query)
            }
            popUpButtonCell.configure(options: options.withEmptyOption(isSelected: condition?.query == nil))
            return popUpButtonCell

        case .value:
            guard let condition = condition,
                  let query = condition.query,
                  query.showConcreteValueField,
                  let fieldId = condition.field,
                  let field = fields.first(where: { $0.id == fieldId }) else {
                return tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            }

            let cellType = elementCellType(for: field.attributes)
            guard let cell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: cellType)) as? ElementCell
            else { preconditionFailure("Expected an ElementCell") }
            cell.delegate = self
            // TODO: label it "Value" instead of the field name
            cell.update(for: field,
                        allElements: [],
                        fieldValue: condition.options?.value)
            return cell
        }
    }

    private func fieldOptions(selecting selectedField: Element?) -> [PopUpButtonCell.Option] {
        let options = fields.map { (field) in
            let isSelected = selectedField == field
            return PopUpButtonCell.Option(title: field.attributes.name ?? "", value: field, isSelected: isSelected)
        }
        return options.withEmptyOption(isSelected: selectedField == nil)
    }

    // MARK: - app-specific delegates

    func didPressButton(inFormCell formCell: UITableViewCell) {
        preconditionFailure("Unexpected call to didPressButton(inFormCell:)")
    }

    func valueDidChange(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else { return }
        valueDidChange(inFormCell: formCell, at: indexPath)
    }
    
    func valueDidChange(inFormCell formCell: UITableViewCell, at indexPath: IndexPath) {
        let rowEnum = Row.allCases[indexPath.row]

        switch rowEnum {
        case .field:
            guard let popUpButtonCell = formCell as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }
            guard let field = popUpButtonCell.selectedValue as? Element?
            else { preconditionFailure("Expected an Element") }
            condition.field = field?.id

        case .query:
            guard let popUpButtonCell = formCell as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }
            guard let query = popUpButtonCell.selectedValue as? Query?
            else { preconditionFailure("Expected a Query") }
            condition.query = query

        case .value:
            preconditionFailure("Unexpected row .value")
        }

        tableView.reloadData() // a change to either field could potentially hide or show value cell
    }

    var fieldValues = [String: FieldValue?]()

    func update(value: FieldValue?, for element: Element) {
        if condition.options == nil {
            condition.options = Condition.Options()
        }
        condition.options?.value = value
    }

    func update(values: [String: FieldValue?], dismiss: Bool) {
        preconditionFailure("Unexpected call to update(values:dismiss:)")
    }

}
