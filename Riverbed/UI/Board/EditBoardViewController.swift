import UIKit

protocol EditBoardViewControllerDelegate: AnyObject {
    func boardDidUpdate(_ board: Board)
}

class EditBoardViewController: UITableViewController,
                               FormCellDelegate {

    enum Row: CaseIterable {
        case name
//        case colorTheme
//        case icon
        case cardCreateWebhook
        case cardUpdateWebhook
        case shareURLField
        case shareTitleField

        var label: String {
            switch self {
            case .name: return "Board Name"
//            case .colorTheme: return "Color Theme"
//            case .icon: return "Icon"
            case .cardCreateWebhook: return "Card Create Webhook"
            case .cardUpdateWebhook: return "Card Update Webhook"
            case .shareURLField: return "Share URL Field"
            case .shareTitleField: return "Share Title Field"
            }
        }
    }

    var boardStore: BoardStore!
    weak var delegate: EditBoardViewControllerDelegate?

    var attributes: Board.Attributes!
    var board: Board! {
        didSet {
            attributes = board.attributes
        }
    }

    var elements: [Element] = [] {
        didSet {
            fields = elements.filter { $0.attributes.elementType == .field }
        }
    }
    var fields: [Element] = []

    // MARK: - view controller lifecycle

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let board = self.board else { return }
        boardStore.update(board, with: attributes) { [weak self] (result) in
            switch result {
            case .success:
                print("SAVED BOARD \(board.id)")
                self?.delegate?.boardDidUpdate(board)
            case let .failure(error):
                print("Error saving card: \(String(describing: error))")
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

        case .cardCreateWebhook:
            guard let textFieldCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }

            textFieldCell.label.text = rowEnum.label
            textFieldCell.delegate = self
            textFieldCell.textField.text = attributes.options?.webhooks?.cardCreate
            return textFieldCell

        case .cardUpdateWebhook:
            guard let textFieldCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }

            textFieldCell.label.text = rowEnum.label
            textFieldCell.delegate = self
            textFieldCell.textField.text = attributes.options?.webhooks?.cardUpdate
            return textFieldCell

        case .shareURLField:
            guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }

            popUpButtonCell.label.text = rowEnum.label
            popUpButtonCell.delegate = self
            let urlField = fields.first { $0.id == attributes.options?.share?.urlField }
            popUpButtonCell.configure(options: fieldOptions(selecting: urlField))
            return popUpButtonCell

        case .shareTitleField:
            guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }

            popUpButtonCell.label.text = rowEnum.label
            popUpButtonCell.delegate = self
            let titleField = fields.first { $0.id == attributes.options?.share?.titleField }
            popUpButtonCell.configure(options: fieldOptions(selecting: titleField))
            return popUpButtonCell
        }
    }

    // MARK: - form cell delegate

    func valueDidChange(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else { return }
        let rowEnum = Row.allCases[indexPath.row]

        switch rowEnum {
        case .name:
            guard let textFieldCell = formCell as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }
            attributes.name = textFieldCell.textField.text

        case .cardCreateWebhook:
            guard let textFieldCell = formCell as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }
            ensureWebhooks()
            attributes?.options?.webhooks?.cardCreate = textFieldCell.textField.text

        case .cardUpdateWebhook:
            guard let textFieldCell = formCell as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }
            ensureWebhooks()
            attributes.options?.webhooks?.cardUpdate = textFieldCell.textField.text

        case .shareURLField:
            guard let popUpButtonCell = formCell as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }
            ensureShare()
            guard let urlField = popUpButtonCell.selectedValue as? Element
            else { preconditionFailure("Expected an Element") }
            attributes.options?.share?.urlField = urlField.id

        case .shareTitleField:
            guard let popUpButtonCell = formCell as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }
            ensureShare()
            guard let titleField = popUpButtonCell.selectedValue as? Element
            else { preconditionFailure("Expected an Element") }
            attributes.options?.share?.titleField = titleField.id
        }
    }

    // MARK: - helper methods

    private func fieldOptions(selecting selectedField: Element?) -> [PopUpButtonCell.Option] {
        let emptyOption = PopUpButtonCell.Option(title: "(none)", value: nil, isSelected: selectedField == nil)
        let options = fields.map { (field) in
            let isSelected = selectedField == field
            return PopUpButtonCell.Option(title: field.attributes.name ?? "", value: field, isSelected: isSelected)
        }
        return [emptyOption] + options
    }

    private func ensureShare() {
        if attributes.options == nil {
            attributes.options = Board.Options()
        }
        if attributes?.options?.share == nil {
            attributes.options?.share = Board.Share()
        }
    }

    private func ensureWebhooks() {
        if attributes.options == nil {
            attributes.options = Board.Options()
        }
        if attributes?.options?.webhooks == nil {
            attributes.options?.webhooks = Board.Webhooks()
        }
    }

}
