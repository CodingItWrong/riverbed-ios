import UIKit

protocol SignInDelegate: AnyObject {
    func didReceive(tokenResponse: TokenResponse)
}

class SignInViewController: UIViewController,
                            UITextFieldDelegate {

    weak var delegate: SignInDelegate?

    var tokenStore: TokenStore!
    var userStore: UserStore!

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = ColorTheme.defaultUIColor
    }

    @IBAction func signIn() {
        tokenStore.create(email: emailField.text ?? "", password: passwordField.text ?? "") { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case let .success(tokenResponse):
                self.delegate?.didReceive(tokenResponse: tokenResponse)
                self.dismiss(animated: true)
            case let .failure(error):
                if let apiError = error as? APIError,
                   case let .serverError(httpStatus, _) = apiError,
                   httpStatus == 400 {
                    self.displayError("Incorrect username or password.")
                } else {
                    self.displayError("An error occurred while attempting to sign in. Please try again.")
                }
            }
        }
    }

    func displayError(_ error: String) {
        errorLabel.text = error
        errorLabel.isHidden = false
    }

    func clearError() {
        errorLabel.isHidden = true
    }

    // MARK: - text field delegate

    func textFieldDidChangeSelection(_ textField: UITextField) {
        clearError()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            passwordField.resignFirstResponder()
            signIn()
        }
        return true
    }

    // MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "signUp":
            guard let navVC = segue.destination as? UINavigationController else {
                preconditionFailure("Expected a UINavigationController")
            }
            guard let signUpVC = navVC.viewControllers.first as? SignUpViewController else {
                preconditionFailure("Expected a SignUpViewController")
            }
            navVC.view.tintColor = view.tintColor
            signUpVC.userStore = userStore
        default:
            preconditionFailure("Unexpected segue identifier: \(segue.identifier ?? "nil")")
        }
    }

}
