import UIKit

protocol EditActionDelegate: AnyObject {
    func didUpdate(_ action: Element.Action)
}

class EditActionViewController: UITableViewController,
                                FormCellDelegate {

    enum Row: CaseIterable {
        case command
        case field
        case value
        case specificValue // this is what is shown for "Add Days"

        static func cases(for action: Element.Action) -> [Row] {
            switch action.command {
            case .none: return [.command, .field]
            case .addDays: return [.command, .field, .specificValue]
            case .setValue:
                // TODO: need .specificValue too for value = specific value
                return [.command, .field, .value]
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
    var action: Element.Action!

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
            preconditionFailure("Expected an EditActionDelegate")
        }

        delegate.didUpdate(action)
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.cases(for: action).count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Edit Action"
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
            popUpButtonCell.configure(options: withEmptyOption(options, isSelected: action.command == nil))
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
            switch action.command {
            case .none: preconditionFailure("Expected a command")
            case .addDays:
                guard let textFieldCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
                else { preconditionFailure("Expected a TextFieldCell") }

                textFieldCell.label.text = rowEnum.label
                textFieldCell.delegate = self
                textFieldCell.textField.text = action.value
                return textFieldCell

            case .setValue:
                guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
                else { preconditionFailure("Expected a PopUpButtonCell") }

                popUpButtonCell.label.text = rowEnum.label
                popUpButtonCell.delegate = self

                let options = Value.allCases.map { (value) in
                    PopUpButtonCell.Option(title: value.label, value: value, isSelected: action.value == value.rawValue)
                }
                popUpButtonCell.configure(options: withEmptyOption(options, isSelected: action.value == nil))
                return popUpButtonCell
            }
        case .specificValue:
            guard let textFieldCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }

            textFieldCell.label.text = "Days to Add"
            textFieldCell.delegate = self
            textFieldCell.textField.text = action.value
            return textFieldCell
        }
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
        case .command:
            guard let popUpButtonCell = formCell as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }
            guard let command = popUpButtonCell.selectedValue as? Command?
            else { preconditionFailure("Expected a Command") }
            action.command = command

        case .field:
            guard let popUpButtonCell = formCell as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }
            guard let field = popUpButtonCell.selectedValue as? Element?
            else { preconditionFailure("Expected an Element") }
            action.field = field?.id

        case .value:
            switch action.command {
            case .none: preconditionFailure("Expected a command")
            case .addDays:
                guard let textFieldCell = formCell as? TextFieldCell
                else { preconditionFailure("Expected a TextFieldCell") }
                action.value = textFieldCell.textField.text

            case .setValue:
                guard let popUpButtonCell = formCell as? PopUpButtonCell
                else { preconditionFailure("Expected a PopUpButtonCell") }
                guard let value = popUpButtonCell.selectedValue as? Value?
                else { preconditionFailure("Expected a Value") }
                action.value = value?.rawValue
            }

        case .specificValue:
            guard let textFieldCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }
            action.value = textFieldCell.textField.text
        }

        tableView.reloadData() // a change to either field could potentially hide or show value cell
    }

}
