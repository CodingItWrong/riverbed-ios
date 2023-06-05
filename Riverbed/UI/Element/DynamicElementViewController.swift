import UIKit

class DynamicElementViewController: UITableViewController, FormCellDelegate {
    enum Section: Int, CaseIterable {
        case element = 0
        case summaryView

        var label: String {
            switch self {
            case .element: return "Element"
            case .summaryView: return "Summary View"
            }
        }
    }

    enum ElementRow: Int, CaseIterable {
        case fieldName = 0
        case dataType
        case showLabelWhenReadOnly
        case readOnly
        case multipleLines

        var label: String {
            switch self {
            case .fieldName: return "Field Name"
            case .dataType: return "Data Type"
            case .showLabelWhenReadOnly: return "Show Label When Read-Only"
            case .readOnly: return "Read-Only"
            case .multipleLines: return "Multiple Lines"
            }
        }
    }

    enum SummaryViewRow: Int, CaseIterable {
        case showField = 0
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

    // MARK: - table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.label
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionEnum = Section(rawValue: section) else { preconditionFailure("Unexpected section") }
        switch sectionEnum {
        case .element: return ElementRow.allCases.count
        case .summaryView: return SummaryViewRow.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        guard let sectionEnum = Section(rawValue: indexPath.section) else { preconditionFailure("Unexpected section") }

        switch sectionEnum {
        case .element:
            guard let rowEnum = ElementRow(rawValue: indexPath.row) else { preconditionFailure("Unexpected row") }
            switch rowEnum {
            case .fieldName:
                guard let textFieldCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: TextFieldCell.self),
                    for: indexPath) as? TextFieldCell else { preconditionFailure("Expected a TextFieldCell") }

                // TODO: maybe set these on a FormCell base class
                textFieldCell.label.text = rowEnum.label
                textFieldCell.delegate = self

                textFieldCell.textField.text = attributes.name
                cell = textFieldCell
            case .dataType:
                guard let popUpButtonCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: PopUpButtonCell.self),
                    for: indexPath) as? PopUpButtonCell else { preconditionFailure("Expected a PopUpButtonCell") }
                popUpButtonCell.label.text = rowEnum.label
                popUpButtonCell.delegate = self
                let dataTypes = Element.DataType.allCases.sorted { $0.label < $1.label }
                popUpButtonCell.configure(options: dataTypes.map { (dataType) in
                    PopUpButtonCell.Option(title: dataType.label,
                                           value: dataType,
                                           isSelected: attributes.dataType == dataType) }
                )
                cell = popUpButtonCell
            case .showLabelWhenReadOnly:
                guard let switchCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SwitchCell.self),
                    for: indexPath) as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.options?.showLabelWhenReadOnly ?? false
                cell = switchCell
            case .readOnly:
                guard let switchCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SwitchCell.self),
                    for: indexPath) as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.readOnly
                cell = switchCell
            case .multipleLines:
                guard let switchCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SwitchCell.self),
                    for: indexPath) as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.options?.multiline ?? false
                cell = switchCell
            }
        case .summaryView:
            guard let rowEnum = SummaryViewRow(rawValue: indexPath.row) else { preconditionFailure("Unexpected row") }
            switch rowEnum {
            case .showField:
                guard let switchCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SwitchCell.self),
                    for: indexPath) as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.showInSummary
                cell = switchCell
            case .textSize:
                guard let popUpButtonCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: PopUpButtonCell.self),
                    for: indexPath) as? PopUpButtonCell else { preconditionFailure("Expected a PopUpButtonCell") }
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
                guard let switchCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SwitchCell.self),
                    for: indexPath) as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.options?.linkURLs ?? false
                cell = switchCell
            case .abbreviateURLs:
                guard let switchCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SwitchCell.self),
                    for: indexPath) as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
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

        switch (indexPath.section, indexPath.row) {
        case (Section.element.rawValue, ElementRow.fieldName.rawValue):
            guard let textFieldCell = formCell as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }
            attributes.name = textFieldCell.textField.text
        case (Section.element.rawValue, ElementRow.dataType.rawValue):
            guard let popUpButtonCell = formCell as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }
            guard let dataType = popUpButtonCell.selectedValue as? Element.DataType
            else { preconditionFailure("Expected an Element.DataType") }
            attributes.dataType = dataType
        case (Section.element.rawValue, ElementRow.showLabelWhenReadOnly.rawValue):
            guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
            if attributes.options == nil {
                attributes.options = Element.Options()
            }
            attributes.options?.showLabelWhenReadOnly = switchCell.switchControl.isOn
        case (Section.element.rawValue, ElementRow.readOnly.rawValue):
            guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
            attributes.readOnly = switchCell.switchControl.isOn
        case (Section.element.rawValue, ElementRow.multipleLines.rawValue):
            guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
            if attributes.options == nil {
                attributes.options = Element.Options()
            }
            attributes.options?.multiline = switchCell.switchControl.isOn
        case (Section.summaryView.rawValue, SummaryViewRow.showField.rawValue):
            guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
            attributes.showInSummary = switchCell.switchControl.isOn
        case (Section.summaryView.rawValue, SummaryViewRow.textSize.rawValue):
            guard let popUpButtonCell = formCell as? PopUpButtonCell else { preconditionFailure("Expected a PopUpButtonCell") }
            if attributes.options == nil {
                attributes.options = Element.Options()
            }
            guard let textSize = popUpButtonCell.selectedValue as? TextSize
            else { preconditionFailure("Expected a TextSize") }
            attributes.options?.textSize = textSize
        case (Section.summaryView.rawValue, SummaryViewRow.linkURLs.rawValue):
            guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
            if attributes.options == nil {
                attributes.options = Element.Options()
            }
            attributes.options?.linkURLs = switchCell.switchControl.isOn
        case (Section.summaryView.rawValue, SummaryViewRow.abbreviateURLs.rawValue):
            guard let switchCell = formCell as? SwitchCell else { preconditionFailure("Expected a SwitchCell") }
            if attributes.options == nil {
                attributes.options = Element.Options()
            }
            attributes.options?.abbreviateURLs = switchCell.switchControl.isOn
        default:
            preconditionFailure("Unexpected index path")
        }
    }

}
