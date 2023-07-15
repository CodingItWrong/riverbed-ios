import UIKit

class UserSettingsViewController: UITableViewController,
                                  FormCellDelegate {

    enum Row: CaseIterable {
        case allowEmails
        case iosShareToBoard

        var label: String {
            switch self {
            case .allowEmails: return "Allow Emails"
            case .iosShareToBoard: return "iOS Share to Board"
            }
        }
    }

    var boards = [Board]()

    var attributes: User.Attributes?
    var user: User? {
        didSet {
            attributes = user?.attributes
            tableView.reloadData()
        }
    }
    var tokenSource: SessionSource!
    var userStore: UserStore!

    // MARK: - view lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let userId = tokenSource.userId else { return }

        userStore.find(userId) { (result) in
            switch result {
            case let .success(user):
                self.user = user
            case let .failure(error):
                print("Error loading user: \(String(describing: error))")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let user = user,
              let attributes = attributes else { return }
        userStore.update(user, with: attributes) { (result) in
            switch result {
            case .success:
                print("User saved")
            case let .failure(error):
                print("Error saving user: \(String(describing: error))")
            }
        }

        // save changes
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowEnum = Row.allCases[indexPath.row]
        switch rowEnum {
        case .allowEmails:
            guard let switchCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: SwitchCell.self)) as? SwitchCell
            else { preconditionFailure("Expected a SwitchCell") }
            switchCell.label.text = rowEnum.label
            switchCell.switchControl.isOn = attributes?.allowEmails ?? false
            switchCell.delegate = self
            return switchCell
        case .iosShareToBoard:
            guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
            else { preconditionFailure("Expected a TextFieldCell") }
            popUpButtonCell.label.text = rowEnum.label
            popUpButtonCell.delegate = self

            let options = boards.map { (board) in
                PopUpButtonCell.Option(title: board.attributes.name ?? Board.defaultName,
                                       value: board,
                                       isSelected: Int(board.id) == attributes?.iosShareToBoard)
            }
            popUpButtonCell.configure(options: withEmptyOption(options, isSelected: attributes?.iosShareToBoard == nil))

            return popUpButtonCell
        }
    }

    // MARK: - private helpers

    private func withEmptyOption(_ options: [PopUpButtonCell.Option],
                                 image: UIImage? = nil,
                                 isSelected: Bool) -> [PopUpButtonCell.Option] {
        let emptyOption = PopUpButtonCell.Option(title: "(none)", image: image, value: nil, isSelected: isSelected)
        return [emptyOption] + options
    }

    // MARK: - app-specific delegates

    func didPressButton(inFormCell formCell: UITableViewCell) {
        preconditionFailure("Unexpected button press")
    }

    func valueDidChange(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else {
            preconditionFailure("Could not find indexPath for cell")
        }
        let rowEnum = Row.allCases[indexPath.row]
        switch rowEnum {
        case .allowEmails:
            guard let switchCell = formCell as? SwitchCell else {
                preconditionFailure("Expected a SwitchCell")
            }
            attributes?.allowEmails = switchCell.switchControl.isOn
        case .iosShareToBoard:
            guard let popUpButtonCell = formCell as? PopUpButtonCell else {
                preconditionFailure("Expected a PopUpButtonCell")
            }
            guard let board = popUpButtonCell.selectedValue as? Board? else {
                preconditionFailure("Expected a Board")
            }
            if let board = board {
                attributes?.iosShareToBoard = Int(board.id)
            } else {
                attributes?.iosShareToBoard = nil
            }
        }
    }

}
