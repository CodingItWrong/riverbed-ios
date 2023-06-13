import UIKit

protocol EditConditionDelegate: AnyObject {
    func didUpdate(_ condition: Condition)
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
        elements.filter { $0.attributes.elementType == .field }
    }

    // MARK: - VC lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // for some reason a dynamic grouped table in a form sheet has this issue
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let delegate = delegate else {
            preconditionFailure("Expected an EditConditionDelegate")
        }

        delegate.didUpdate(condition)
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.cases(for: condition).count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Edit Condition"
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
            popUpButtonCell.configure(options: withEmptyOption(options, isSelected: condition?.query == nil))
            return popUpButtonCell

        case .value:
            guard let condition = condition,
                  let query = condition.query,
                  query.showConcreteValueField,
                  let fieldId = condition.field,
                  let field = fields.first(where: { $0.id == fieldId }) else {
                return tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            }

            let cellType = elementCellType(for: field)
            guard let cell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: cellType)) as? ElementCell
            else { preconditionFailure("Expected an ElementCell") }
            cell.delegate = self
            var fieldValue: FieldValue?
            if let stringValue = condition.options?.value {
                fieldValue = .string(stringValue)
            }
            // TODO: label it "Value" instead of the field name
            // TODO: geolocation somehow
            cell.update(for: field,
                        allElements: [],
                        fieldValue: fieldValue)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        print("willDisplay \(indexPath)")
    }

    private func fieldOptions(selecting selectedField: Element?) -> [PopUpButtonCell.Option] {
        let options = fields.map { (field) in
            let isSelected = selectedField == field
            return PopUpButtonCell.Option(title: field.attributes.name ?? "", value: field, isSelected: isSelected)
        }
        return withEmptyOption(options, isSelected: selectedField == nil)
    }

    private func withEmptyOption(_ options: [PopUpButtonCell.Option],
                                 image: UIImage? = nil,
                                 isSelected: Bool) -> [PopUpButtonCell.Option] {
        let emptyOption = PopUpButtonCell.Option(title: "(none)", image: image, value: nil, isSelected: isSelected)
        return [emptyOption] + options
    }

    // MARK: - app-specific delegates

    func didPressButton(inFormCell formCell: UITableViewCell) {
        preconditionFailure("Unexpected call to didPressButton(inFormCell:)")
    }

    func valueDidChange(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else { return }
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
        guard case let .string(stringValue) = value else {
            preconditionFailure("Unexpected FieldValue \(String(describing: value))")
        }

        if condition.options == nil {
            condition.options = Condition.Options()
        }
        condition.options?.value = stringValue
    }

    func update(values: [String: FieldValue?], dismiss: Bool) {
        preconditionFailure("Unexpected call to update(values:dismiss:)")
    }

}
