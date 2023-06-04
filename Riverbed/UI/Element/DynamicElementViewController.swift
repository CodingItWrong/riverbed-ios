import UIKit

class DynamicElementViewController: UITableViewController, FormCellDelegate {
    enum Section: Int, CaseIterable {
        case element = 0

        var label: String {
            switch self {
            case .element: return "Element"
            }
        }
    }

    enum ElementRow: Int, CaseIterable {
        case fieldName = 0

        var label: String {
            switch self {
            case .fieldName: return "Field Name"
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

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.label
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionEnum = Section(rawValue: section) else { preconditionFailure("Unexpected section") }
        switch sectionEnum {
        case .element: return ElementRow.allCases.count
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
            }
        }

        return cell
    }

    // MARK: - form cell delegate

    func valueDidChange(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else { return }

        switch formCell {
        case let textFieldCell as TextFieldCell:
            switch (indexPath.section, indexPath.row) {
            case (Section.element.rawValue, ElementRow.fieldName.rawValue):
                attributes.name = textFieldCell.textField.text
            default:
                preconditionFailure("Unexpected index path")
            }
        default:
            preconditionFailure("Unexpected form cell class")
        }
    }

}
