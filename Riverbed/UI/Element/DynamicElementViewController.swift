import UIKit

protocol ElementViewControllerDelegate: AnyObject {
    func elementDidUpdate(_ element: Element)
}

class DynamicElementViewController: UITableViewController, FormCellDelegate, ElementCellDelegate {

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
        case initialValue
        case concreteInitialValue
        case showLabelWhenReadOnly
        case readOnly
        case multipleLines

        static func cases(for elementType: Element.ElementType) -> [ElementRow] {
            switch elementType {
            case .field: return allCases
            case .button: return [.elementName]
            case .buttonMenu: return [.elementName]
            }
        }

        var label: String {
            switch self {
            case .elementName: return "Field Name"
            case .dataType: return "Data Type"
            case .initialValue: return "Initial Value"
            case .concreteInitialValue: return "Initial Value"
            case .showLabelWhenReadOnly: return "Show Label When Read-Only"
            case .readOnly: return "Read-Only"
            case .multipleLines: return "Multiple Lines"
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

    var elementStore: ElementStore!
    weak var delegate: ElementViewControllerDelegate?

    var attributes: Element.Attributes!
    var element: Element! {
        didSet {
            attributes = element.attributes
        }
    }

    // MARK: - view controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // for some reason a dynamic grouped table in a popover has this issue
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let element = self.element else { return }
        elementStore.update(element, with: attributes) { [weak self] (result) in
            switch result {
            case .success:
                print("SAVED ELEMENT \(element.id)")
                self?.delegate?.elementDidUpdate(element)
            case let .failure(error):
                print("Error saving card: \(String(describing: error))")
            }
        }
    }

    // MARK: - table view data source and immediate helpers

    private var sectionCases: [Section] {
        Section.cases(for: element.attributes.elementType)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sectionCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionCases[section].label
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionCases[section] {
        case .element: return ElementRow.cases(for: element.attributes.elementType).count
        case .summaryView: return SummaryViewRow.allCases.count
        }
    }

    private var elementRowCases: [ElementRow] {
        ElementRow.cases(for: element.attributes.elementType)
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
                textFieldCell.label.text = "\(element.attributes.elementType.label) Label"
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
                popUpButtonCell.configure(options: dataTypes.map { (dataType) in
                    PopUpButtonCell.Option(title: dataType.label,
                                           value: dataType,
                                           isSelected: attributes.dataType == dataType) }
                )
                cell = popUpButtonCell
            case .concreteInitialValue:
                guard let usesConcreteValue = attributes.initialValue?.usesConcreteValue,
                      usesConcreteValue else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                    return cell
                }

                let cellType = elementCellType(for: element)
                guard let cell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: cellType)) as? ElementCell
                else { preconditionFailure("Expected an ElementCell") }
                cell.delegate = self
                cell.update(for: element,
                            allElements: [],
                            fieldValue: attributes.options?.initialSpecificValue)
                return cell
            case .initialValue:
                guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                    withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
                else { preconditionFailure("Expected a PopUpButtonCell") }
                popUpButtonCell.label.text = rowEnum.label
                popUpButtonCell.delegate = self
                let values = Value.allCases.sorted { $0.label < $1.label }
                popUpButtonCell.configure(options: values.map { (valueEntry) in
                    PopUpButtonCell.Option(title: valueEntry.label,
                                           value: valueEntry,
                                           isSelected: attributes.initialValue == valueEntry) }
                )
                cell = popUpButtonCell
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

    // MARK: - form cell delegate

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
            case .initialValue:
                guard let popUpButtonCell = formCell as? PopUpButtonCell
                else { preconditionFailure("Expected a PopUpButtonCell") }
                guard let initialValue = popUpButtonCell.selectedValue as? Value
                else { preconditionFailure("Expected a Value") }
                attributes.initialValue = initialValue
                tableView.reloadData() // can trigger hide or show of initial specific value row
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
                preconditionFailure("Unexpected valueDidChange for concreteInitialValue")
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

    // MARK: - element cell delegate for concrete initial value

    var fieldValues = [String: FieldValue?]()

    func update(value: FieldValue?, for element: Element) {
        ensureOptionsPresent()
        attributes.options?.initialSpecificValue = value
    }

    func update(values: [String: FieldValue?], dismiss: Bool) {
        preconditionFailure("Unexpected update(values:dismiss:) call")
    }

    // MARK: - private helpers

    private func ensureOptionsPresent() {
        if attributes.options == nil {
            attributes.options = Element.Options()
        }
    }

}
