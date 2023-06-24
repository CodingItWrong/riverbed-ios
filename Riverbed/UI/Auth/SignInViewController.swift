import UIKit

protocol SignInDelegate: AnyObject {
    func didReceive(tokenResponse: TokenStore.TokenResponse)
}

class SignInViewController: UIViewController {

    weak var delegate: SignInDelegate?

    var tokenStore: TokenStore!

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = ColorTheme.defaultUIColor
    }

    @IBAction func signIn() {
        tokenStore.create(email: emailField.text ?? "", password: passwordField.text ?? "") { [weak self] (result) in
            switch result {
            case let .success(tokenResponse):
                guard let self = self else { return }
                self.delegate?.didReceive(tokenResponse: tokenResponse)
                self.dismiss(animated: true)
            case let .failure(error):
                print("Error signing in: \(error)")
            }
        }
    }

}
