import UIKit

protocol SignInDelegate: AnyObject {
    func didReceive(accessToken: String)
}

class SignInViewController: UIViewController {

    weak var delegate: SignInDelegate?

    var tokenStore: TokenStore!

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!

    @IBAction func signIn() {
        tokenStore.create(email: emailField.text ?? "", password: passwordField.text ?? "") { [weak self] (result) in
            switch result {
            case let .success(accessToken):
                guard let self = self else { return }
                self.delegate?.didReceive(accessToken: accessToken)
                self.dismiss(animated: true)
            case let .failure(error):
                print("Error signing in: \(error)")
            }
        }
    }

}
