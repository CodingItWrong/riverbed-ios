import UIKit

class SignUpViewController: UITableViewController,
                            FormCellDelegate,
                            UITextFieldDelegate {

    enum Row: CaseIterable {
        case email
        case password
        case passwordConfirmation
        case allowEmails
        case signUpButton

        var label: String {
            switch self {
            case .email: return  "Email Address"
            case .password: return "Password"
            case .passwordConfirmation: return "Confirm Password"
            case .allowEmails: return "Allow important emails about your account?"
            case .signUpButton: return "Sign up"
            }
        }
    }

    var userStore: UserStore!
    @IBOutlet var errorLabel: UILabel!

    var attributes = NewUser.Attributes()
    var passwordConfirmation: String = ""

    func displayError(_ error: String) {
        errorLabel.text = error
        errorLabel.isHidden = false
    }

    func clearError() {
        errorLabel.isHidden = true
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowEnum = Row.allCases[indexPath.row]
        switch rowEnum {
        case .email:
            guard let textFieldCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }

            textFieldCell.label.text = rowEnum.label
            textFieldCell.delegate = self
            textFieldCell.textField.isSecureTextEntry = false
            textFieldCell.textField.keyboardType = .emailAddress
            textFieldCell.textField.textContentType = .username
            textFieldCell.textField.autocapitalizationType = .none
            textFieldCell.textField.autocorrectionType = .no
            textFieldCell.textField.text = attributes.email
            return textFieldCell

        case .password:
            guard let textFieldCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }

            textFieldCell.label.text = rowEnum.label
            textFieldCell.delegate = self
            textFieldCell.textField.isSecureTextEntry = true
            textFieldCell.textField.keyboardType = .default
            textFieldCell.textField.textContentType = .newPassword
            textFieldCell.textField.autocapitalizationType = .none
            textFieldCell.textField.autocorrectionType = .no
            textFieldCell.textField.text = attributes.password
            return textFieldCell

        case .passwordConfirmation:
            guard let textFieldCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: TextFieldCell.self)) as? TextFieldCell
            else { preconditionFailure("Expected a TextFieldCell") }

            textFieldCell.label.text = rowEnum.label
            textFieldCell.delegate = self
            textFieldCell.textField.isSecureTextEntry = true
            textFieldCell.textField.keyboardType = .default
            textFieldCell.textField.textContentType = .newPassword
            textFieldCell.textField.autocapitalizationType = .none
            textFieldCell.textField.autocorrectionType = .no
            textFieldCell.textField.text = passwordConfirmation
            return textFieldCell

        case .allowEmails:
            guard let popUpButtonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: PopUpButtonCell.self)) as? PopUpButtonCell
            else { preconditionFailure("Expected a PopUpButtonCell") }
            popUpButtonCell.label.text = rowEnum.label
            popUpButtonCell.delegate = self
            popUpButtonCell.configure(options: [
                PopUpButtonCell.Option(title: "(choose)", value: nil, isSelected: attributes.allowEmails == nil),
                PopUpButtonCell.Option(title: "No", value: false, isSelected: attributes.allowEmails == false),
                PopUpButtonCell.Option(title: "Yes", value: true, isSelected: attributes.allowEmails == true)
            ])
            return popUpButtonCell

        case .signUpButton:
            guard let buttonCell = tableView.dequeueOrRegisterReusableCell(
                withIdentifier: String(describing: ButtonCell.self)) as? ButtonCell
            else { preconditionFailure("Expected a ButtonCell") }

            buttonCell.label.text = nil
            if #available(iOS 26, *) {
                buttonCell.button.configuration = .prominentGlass()
            }
            buttonCell.button.setTitle(rowEnum.label, for: .normal)
            buttonCell.delegate = self
            return buttonCell
        }
    }

    // MARK: - app-specific delegates

    func textFieldDidChangeSelection(_ textField: UITextField) {
        clearError()
    }

    func didPressButton(inFormCell formCell: UITableViewCell) {
        // validate
        if attributes.email == "" {
            displayError("Email is required")
        } else if !isValidEmail(attributes.email) {
            displayError("Email does not appear to be a valid email address")
        } else if attributes.password == "" {
            displayError("Password is required")
        } else if attributes.password.count < 8 {
            displayError("Password must be at least 8 characters")
        } else if passwordConfirmation != attributes.password {
            displayError("Passwords do not match")
        } else if attributes.allowEmails == nil {
            displayError("Please choose whether or not to allow emails")
        } else {
            userStore.create(with: attributes) { [weak self] result in
                switch result {
                case .failure:
                    self?.displayError("An error occurred while creating your account. Please try again.")
                    return
                case .success:
                    let message = "Congratulations, your Riverbed account has been created! " +
                    "You can now log in with the username and password you provided."
                    let alert = UIAlertController(title: "Account Created",
                                                  message: message,
                                                  preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                        self?.dismiss(animated: true)
                    }
                    alert.addAction(okAction)
                    alert.preferredAction = okAction
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    func valueDidChange(inFormCell formCell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: formCell) else {
            preconditionFailure("Could not find indexPath for cell")
        }
        valueDidChange(inFormCell: formCell, at: indexPath)
    }
    
    func valueDidChange(inFormCell formCell: UITableViewCell, at indexPath: IndexPath) {
        clearError()
        let rowEnum = Row.allCases[indexPath.row]
        switch rowEnum {
        case .email:
            guard let textFieldCell = formCell as? TextFieldCell else {
                preconditionFailure("Expected a TextFieldCell")
            }
            guard let email = textFieldCell.textField.text else {
                preconditionFailure("Expected a string")
            }
            attributes.email = email
        case .password:
            guard let textFieldCell = formCell as? TextFieldCell else {
                preconditionFailure("Expected a TextFieldCell")
            }
            guard let password = textFieldCell.textField.text else {
                preconditionFailure("Expected a string")
            }
            attributes.password = password
        case .passwordConfirmation:
            guard let textFieldCell = formCell as? TextFieldCell else {
                preconditionFailure("Expected a TextFieldCell")
            }
            guard let password = textFieldCell.textField.text else {
                preconditionFailure("Expected a string")
            }
            passwordConfirmation = password
        case .allowEmails:
            guard let popUpButtonCell = formCell as? PopUpButtonCell else {
                preconditionFailure("Expected a PopUpButtonCell")
            }
            guard let allowEmails = popUpButtonCell.selectedValue as? Bool? else {
                preconditionFailure("Expected a Bool?")
            }
            attributes.allowEmails = allowEmails
        case .signUpButton:
            preconditionFailure("Unexpected call to valueDidChange(inFormCell:) for sign up button")
        }
    }

}
