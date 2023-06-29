import UIKit

protocol EditActionDelegate: AnyObject {
    func didUpdate(_ action: Action)
}

class EditActionViewController: UITableViewController,
                                FormCellDelegate {

    enum Row: CaseIterable {
        case command
        case field
        case value
        case specificValue

        static func cases(for action: Action) -> [Row] {
            switch action.command {
            case .none: return [.command, .field]
            case .addDays: return [.command, .field, .specificValue]
            case .setValue:
                if action.value == .specificValue {
                    return [.command, .field, .value, .specificValue]
                } else {
                    return [.command, .field, .value]
                }
            }
        }

        var label: String {
            switch self {
            case .command: return "Command"
            case .field: return "Field"
            case .value: return "Value"
            case .specificValue: return "Specific Value"
            }
        }
    }

    weak var delegate: EditActionDelegate?
    var action: Action!

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

        delegate.didUpdate(action)
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.cases(for: action).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowEnum = Row.cases(for: action)[indexPath.row]
        print("Configuring cell for row \(rowEnum.label)")
        switch rowEnum {
        case .command:
            guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }

            popUpButtonCell.label.text = rowEnum.label
            popUpButtonCell.delegate = self
            let options = Command.allCases.map { (command) in
                PopUpButtonCell.Option(title: command.label, value: command, isSelected: action.command == command)
            }
            popUpButtonCell.configure(options: options.withEmptyOption(isSelected: action.command == nil))
            return popUpButtonCell

        case .field:
            guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }

            popUpButtonCell.label.text = rowEnum.label
            popUpButtonCell.delegate = self
            let selectedField = fields.first { $0.id == action?.field }
            popUpButtonCell.configure(options: fieldOptions(selecting: selectedField))
            return popUpButtonCell

        case .value:
            guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }

            popUpButtonCell.label.text = rowEnum.label
            popUpButtonCell.delegate = self

            let options = Value.allCases.map { (value) in
                PopUpButtonCell.Option(title: value.label, value: value, isSelected: action.value == value)
            }
            popUpButtonCell.configure(options: options.withEmptyOption(isSelected: action.value == nil))
            return popUpButtonCell
        case .specificValue:
            guard let textFieldCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }

            textFieldCell.label.text = action.command == .addDays ? "Days to Add" : "Specific Value"
            textFieldCell.delegate = self

            // TODO: handle geolocation value?
            switch action.specificValue {
            case let .string(stringValue): textFieldCell.textField.text = stringValue
            case .none: textFieldCell.textField.text = ""
            default: preconditionFailure("Unexpected specificValue case: \(String(describing: action.specificValue))")
            }

            return textFieldCell
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
        let rowEnum = Row.allCases[indexPath.row]

        switch rowEnum {
        case .command:
            guard let popUpButtonCell = formCell as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }
            guard let command = popUpButtonCell.selectedValue as? Command?
            else { preconditionFailure("Expected a Command") }
            action.command = command
            tableView.reloadData()

        case .field:
            guard let popUpButtonCell = formCell as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }
            guard let field = popUpButtonCell.selectedValue as? Element?
            else { preconditionFailure("Expected an Element") }
            action.field = field?.id
            tableView.reloadData()

        case .value:
            guard let popUpButtonCell = formCell as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }
            guard let value = popUpButtonCell.selectedValue as? Value?
            else { preconditionFailure("Expected a Value") }
            action.value = value
            tableView.reloadData() // TODO: this causes the popup closing to jumpf

        case .specificValue:
            guard let textFieldCell = formCell as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }
            if let text = textFieldCell.textField.text {
                action.specificValue = .string(text)
            } else {
                action.specificValue = nil
            }
        }
    }

}
