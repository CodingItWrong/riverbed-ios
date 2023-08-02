import UIKit

class EditElementViewController: UITableViewController,
                                 ActionsDelegate,
                                 ButtonMenuItemsDelegate,
                                 ChoicesDelegate,
                                 ConditionsDelegate,
                                 ElementCellDelegate,
                                 FormCellDelegate {

    enum Section: CaseIterable {
        case element
        case summaryView

        static func cases(for elementType: Element.ElementType) -> [Section] {
            switch elementType {
            case .field: return allCases
            case .button: return [.element]
            case .buttonMenu: return [.element]
            }
        }

        var label: String {
            switch self {
            case .element: return "Element"
            case .summaryView: return "Summary View"
            }
        }
    }

    enum ElementRow: CaseIterable {
        case elementName
        case dataType
        case choices
        case initialValue
        case concreteInitialValue
        case showLabelWhenReadOnly
        case readOnly
        case multipleLines
        case actions
        case menuItems
        case showConditions

        static func cases(forElementType elementType: Element.ElementType,
                          dataType: Element.DataType?) -> [ElementRow] {
            switch elementType {
            case .field:
                switch dataType {
                case .choice:
                    return [.elementName,
                            .dataType,
                            .choices,
                            .initialValue,
                            .concreteInitialValue,
                            .showLabelWhenReadOnly,
                            .readOnly,
                            .multipleLines,
                            .showConditions]
                default:
                    return [.elementName,
                            .dataType,
                            .initialValue,
                            .concreteInitialValue,
                            .showLabelWhenReadOnly,
                            .readOnly,
                            .multipleLines,
                            .showConditions]
                }
            case .button:
                return [.elementName,
                        .actions,
                        .showConditions]
            case .buttonMenu:
                return [.elementName,
                        .menuItems,
                        .showConditions]
            }
        }

        var label: String {
            switch self {
            case .elementName: preconditionFailure("Expected to use a dynamic label")
            case .dataType: return "Data Type"
            case .choices: return "Choices"
            case .initialValue: return "Initial Value"
            case .concreteInitialValue: return "Initial Value"
            case .showLabelWhenReadOnly: return "Show Label When Read-Only"
            case .readOnly: return "Read-Only"
            case .multipleLines: return "Multiple Lines"
            case .actions: return "Actions"
            case .menuItems: return "Menu Items"
            case .showConditions: return "Show Conditions"
            }
        }
    }

    enum SummaryViewRow: CaseIterable {
        case showField
        case textSize
        case linkURLs
        case abbreviateURLs

        var label: String {
            switch self {
            case .showField: return "Show Field"
            case .textSize: return "Text Size"
            case .linkURLs: return "Link URLs"
            case .abbreviateURLs: return "Abbreviate URLs"
            }
        }
    }

    var element: Element!
    var attributes: Element.Attributes! {
        didSet {
            navigationItem.title = "Edit \(attributes.elementType.label)"
        }
    }
    var elements = [Element]()

    // MARK: - table view data source and immediate helpers

    private var sectionCases: [Section] {
        Section.cases(for: attributes.elementType)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sectionCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionCases[section].label
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionCases[section] {
        case .element: return elementRowCases.count
        case .summaryView: return SummaryViewRow.allCases.count
        }
    }

    private var elementRowCases: [ElementRow] {
        ElementRow.cases(forElementType: attributes.elementType,
                         dataType: attributes.dataType)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        switch sectionCases[indexPath.section] {
        case .element:
            let rowEnum = elementRowCases[indexPath.row]
            switch rowEnum {
            case .elementName:
                guard let textFieldCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
                else { preconditionFailure("Expected a TextFieldCell") }

                // TODO: maybe set these on a FormCell base class
                textFieldCell.label.text = "\(attributes.elementType.label) Name"
                textFieldCell.delegate = self

                textFieldCell.textField.text = attributes.name
                cell = textFieldCell
            case .dataType:
                guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
                else { preconditionFailure("Expected a PopUpButtonCell") }
                popUpButtonCell.label.text = rowEnum.label
                popUpButtonCell.delegate = self
                let dataTypes = Element.DataType.allCases.sorted { $0.label < $1.label }
                let dataTypeOptions = dataTypes.map { (dataType) in
                    PopUpButtonCell.Option(title: dataType.label,
                                           value: dataType,
                                           isSelected: attributes.dataType == dataType)
                }
                popUpButtonCell.configure(options: dataTypeOptions)
                cell = popUpButtonCell
            case .choices:
                guard let buttonCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: ButtonCell.self)) as? ButtonCell
                else { preconditionFailure("Expected a ButtonCell") }

                buttonCell.delegate = self
                buttonCell.label.text = rowEnum.label
                let choicesCount = attributes.options?.choices?.count ?? 0

                let buttonTitle: String = {
                    switch choicesCount {
                    case 0:
                        return "None"
                    case 1:
                        return "\(choicesCount) choice"
                    default:
                        return "\(choicesCount) choices"
                    }
                }()
                buttonCell.button.setTitle(buttonTitle, for: .normal)
                return buttonCell
            case .initialValue:
                guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
                else { preconditionFailure("Expected a PopUpButtonCell") }
                popUpButtonCell.label.text = rowEnum.label
                popUpButtonCell.delegate = self
                let values = Value.allCases.sorted { $0.label < $1.label }
                let valueOptions = values.map { (valueEntry) in
                    PopUpButtonCell.Option(title: valueEntry.label,
                                           value: valueEntry,
                                           isSelected: attributes.initialValue == valueEntry)
                }
                popUpButtonCell.configure(options: valueOptions.withEmptyOption(
                    title: "(choose)", isSelected: attributes.initialValue == nil))
                cell = popUpButtonCell
            case .concreteInitialValue:
                guard let usesConcreteValue = attributes.initialValue?.usesConcreteValue,
                      usesConcreteValue else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                    return cell
                }

                let cellType = elementCellType(for: attributes)
                guard let cell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: cellType)) as? ElementCell
                else { preconditionFailure("Expected an ElementCell") }
                cell.delegate = self
                cell.update(for: element,
                            allElements: [],
                            fieldValue: attributes.options?.initialSpecificValue)
                return cell
            case .showLabelWhenReadOnly:
                guard let switchCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
                else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.options?.showLabelWhenReadOnly ?? false
                cell = switchCell
            case .readOnly:
                guard let switchCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
                else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.readOnly
                cell = switchCell
            case .multipleLines:
                guard let switchCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
                else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.options?.multiline ?? false
                cell = switchCell
            case .actions:
                guard let buttonCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: ButtonCell.self)) as? ButtonCell
                else { preconditionFailure("Expected a ButtonCell") }

                buttonCell.delegate = self
                buttonCell.label.text = rowEnum.label
                let actionCount = attributes.options?.actions?.count ?? 0

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
            case .menuItems:
                guard let buttonCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: ButtonCell.self)) as? ButtonCell
                else { preconditionFailure("Expected a ButtonCell") }

                buttonCell.delegate = self
                buttonCell.label.text = rowEnum.label
                let actionCount = attributes.options?.items?.count ?? 0

                let buttonTitle: String = {
                    switch actionCount {
                    case 0:
                        return "(none)"
                    case 1:
                        return "\(actionCount) menu item"
                    default:
                        return "\(actionCount) menu items"
                    }
                }()
                buttonCell.button.setTitle(buttonTitle, for: .normal)
                return buttonCell
            case .showConditions:
                guard let buttonCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: ButtonCell.self)) as? ButtonCell
                else { preconditionFailure("Expected a ButtonCell") }

                buttonCell.delegate = self
                buttonCell.label.text = rowEnum.label
                let conditionCount = attributes.showConditions?.count ?? 0

                let buttonTitle: String = {
                    switch conditionCount {
                    case 0:
                        return "Always show"
                    case 1:
                        return "\(conditionCount) condition"
                    default:
                        return "\(conditionCount) conditions"
                    }
                }()
                buttonCell.button.setTitle(buttonTitle, for: .normal)
                return buttonCell
            }
        case .summaryView:
            let rowEnum = SummaryViewRow.allCases[indexPath.row]
            switch rowEnum {
            case .showField:
                guard let switchCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
                else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.showInSummary
                cell = switchCell
            case .textSize:
                guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
                else { preconditionFailure("Expected a PopUpButtonCell") }
                popUpButtonCell.label.text = rowEnum.label
                popUpButtonCell.delegate = self
                let selectedTextSize = attributes.options?.textSize ?? TextSize.defaultTextSize
                popUpButtonCell.configure(options: TextSize.allCases.map { (textSize) in
                    PopUpButtonCell.Option(title: textSize.label,
                                           value: textSize,
                                           isSelected: textSize == selectedTextSize) }
                )
                cell = popUpButtonCell
            case .linkURLs:
                guard let switchCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
                else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.options?.linkURLs ?? false
                cell = switchCell
            case .abbreviateURLs:
                guard let switchCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
                else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.options?.abbreviateURLs ?? false
                cell = switchCell
            }
        }

        return cell
    }

    // MARK: - app-specific delegates

    func didPressButton(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else { return }

        let sectionEnum = Section.cases(for: attributes.elementType)[indexPath.section]
        guard sectionEnum == .element else { preconditionFailure("Unexpected section \(indexPath.section)") }

        let rowEnum = elementRowCases[indexPath.row]
        switch rowEnum {
        case .choices: performSegue(withIdentifier: "choices", sender: self)
        case .showConditions: performSegue(withIdentifier: "showConditions", sender: self)
        case .actions: performSegue(withIdentifier: "actions", sender: self)
        case .menuItems: performSegue(withIdentifier: "menuItems", sender: self)
        default: preconditionFailure("Unexpected row \(indexPath.row)")
        }
    }

    func valueDidChange(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else { return }
        let sectionEnum = sectionCases[indexPath.section]

        switch sectionEnum {
        case .element:
            let elementRowEnum = elementRowCases[indexPath.row]
            switch elementRowEnum {
            case .elementName:
                guard let textFieldCell = formCell as? TextFieldCell
                else { preconditionFailure("Expected a TextFieldCell") }
                attributes.name = textFieldCell.textField.text
            case .dataType:
                guard let popUpButtonCell = formCell as? PopUpButtonCell
                else { preconditionFailure("Expected a PopUpButtonCell") }
                guard let dataType = popUpButtonCell.selectedValue as? Element.DataType
                else { preconditionFailure("Expected an Element.DataType") }
                attributes.dataType = dataType
                tableView.reloadData() // in case of choice row added or removed
            case .choices:
                preconditionFailure("Unexpected valueDidChange for form cell choices")
            case .initialValue:
                guard let popUpButtonCell = formCell as? PopUpButtonCell
                else { preconditionFailure("Expected a PopUpButtonCell") }
                guard let initialValue = popUpButtonCell.selectedValue as? Value?
                else { preconditionFailure("Expected a Value") }
                attributes.initialValue = initialValue
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    // delay to wait for menu to dismiss
                    self.tableView.reloadData() // can trigger hide or show of initial specific value row
                }
            case .showLabelWhenReadOnly:
                guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
                ensureOptionsPresent()
                attributes.options?.showLabelWhenReadOnly = switchCell.switchControl.isOn
            case .readOnly:
                guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
                attributes.readOnly = switchCell.switchControl.isOn
            case .multipleLines:
                guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
                ensureOptionsPresent()
                attributes.options?.multiline = switchCell.switchControl.isOn
            case .concreteInitialValue:
                preconditionFailure("Unexpected valueDidChange for from cell concreteInitialValue")
            case .actions:
                preconditionFailure("Unexpected valueDidChange for form cell actions")
            case .menuItems:
                preconditionFailure("Unexpected valueDidChange for form cell menuItems")
            case .showConditions:
                preconditionFailure("Unexpected valueDidChange for form cell showConditions")
            }
        case .summaryView:
            let summaryViewRowEnum = SummaryViewRow.allCases[indexPath.row]
            switch summaryViewRowEnum {
            case .showField:
                guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
                attributes.showInSummary = switchCell.switchControl.isOn
            case .textSize:
                guard let popUpButtonCell = formCell as? PopUpButtonCell
                else { preconditionFailure("Expected a PopUpButtonCell") }
                guard let textSize = popUpButtonCell.selectedValue as? TextSize
                else { preconditionFailure("Expected a TextSize") }
                ensureOptionsPresent()
                attributes.options?.textSize = textSize
            case .linkURLs:
                guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
                ensureOptionsPresent()
                attributes.options?.linkURLs = switchCell.switchControl.isOn
            case .abbreviateURLs:
                guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
                ensureOptionsPresent()
                attributes.options?.abbreviateURLs = switchCell.switchControl.isOn
            }
        }
    }

    var fieldValues = [String: FieldValue?]()

    func update(value: FieldValue?, for element: Element) {
        ensureOptionsPresent()
        attributes.options?.initialSpecificValue = value
    }

    func update(values: [String: FieldValue?], dismiss: Bool) {
        preconditionFailure("Unexpected update(values:dismiss:) call")
    }

    func didUpdate(conditions: [Condition]) {
        attributes.showConditions = conditions
        tableView.reloadData()
    }

    func didUpdate(actions: [Action]) {
        ensureOptionsPresent()
        attributes.options?.actions = actions
        tableView.reloadData()
    }

    func didUpdate(choices: [Element.Choice]) {
        ensureOptionsPresent()
        attributes.options?.choices = choices
        tableView.reloadData()
    }

    func didUpdate(items: [Element.Item]) {
        ensureOptionsPresent()
        attributes.options?.items = items
        tableView.reloadData()
    }

    // MARK: - private helpers

    private func ensureOptionsPresent() {
        if attributes.options == nil {
            attributes.options = Element.Options()
        }
    }

    // MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "choices":
            guard let choicesVC = segue.destination as? ChoicesViewController else {
                preconditionFailure("Expected a ChoicesViewController")
            }

            choicesVC.choices = attributes.options?.choices ?? []
            choicesVC.delegate = self

        case "showConditions":
            guard let conditionsVC = segue.destination as? ConditionsViewController else {
                preconditionFailure("Expected a ConditionsViewController")
            }

            conditionsVC.navigationItem.title = "Show Conditions"
            conditionsVC.conditions = attributes.showConditions ?? []
            conditionsVC.elements = elements
            conditionsVC.delegate = self

        case "actions":
            guard let actionsVC = segue.destination as? ActionsViewController else {
                preconditionFailure("Expected an ActionsViewController")
            }

            actionsVC.actions = attributes.options?.actions ?? []
            actionsVC.elements = elements
            actionsVC.delegate = self

        case "menuItems":
            guard let itemsVC = segue.destination as? ButtonMenuItemsViewController else {
                preconditionFailure("Expected a ButtonMenuItemsViewController")
            }

            itemsVC.items = attributes.options?.items ?? []
            itemsVC.elements = elements
            itemsVC.delegate = self

        default:
            preconditionFailure("Unexpected segue \(String(describing: segue.identifier))")
        }
    }

}
