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
        case showLabelWhenReadOnly
        case readOnly
        case multipleLines

        var label: String {
            switch self {
            case .fieldName: return "Field Name"
            case .showLabelWhenReadOnly: return "Show Label When Read-Only"
            case .readOnly: return "Read-Only"
            case .multipleLines: return "Multiple Lines"
            }
        }
    }

    enum SummaryViewRow: Int, CaseIterable {
        case showField = 0
        case linkURLs
        case abbreviateURLs

        var label: String {
            switch self {
            case .showField: return "Show Field"
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
                    withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
                else { preconditionFailure("Expected a TextFieldCell") }

                // TODO: maybe set these on a FormCell base class
                textFieldCell.label.text = rowEnum.label
                textFieldCell.delegate = self

                textFieldCell.textField.text = attributes.name
                cell = textFieldCell
            case .showLabelWhenReadOnly:
                guard let switchCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
                else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.options?.showLabelWhenReadOnly ?? false
                cell = switchCell
            case .readOnly:
                guard let switchCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
                else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.readOnly
                cell = switchCell
            case .multipleLines:
                guard let switchCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
                else { preconditionFailure("Expected a SwitchCell") }
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
                    withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
                else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.showInSummary
                cell = switchCell
            case .linkURLs:
                guard let switchCell = tableView.dequeueReusableCell(
                    withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
                else { preconditionFailure("Expected a SwitchCell") }
                switchCell.label.text = rowEnum.label
                switchCell.delegate = self
                switchCell.switchControl.isOn = attributes.options?.linkURLs ?? false
                cell = switchCell
            case .abbreviateURLs:
                guard let switchCell = tableView.dequeueReusableCell(
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

        switch (indexPath.section, indexPath.row) {
        case (Section.element.rawValue, ElementRow.fieldName.rawValue):
            guard let textFieldCell = formCell as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }
            attributes.name = textFieldCell.textField.text
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
