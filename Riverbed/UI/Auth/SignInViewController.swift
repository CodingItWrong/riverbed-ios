import UIKit

protocol SignInDelegate: AnyObject {
    func didReceive(accessToken: String)
}

class SignInViewController: UIViewController {

    weak var delegate: SignInDelegate?

    @IBAction func signIn() {
        dismiss(animated: true)
        delegate?.didReceive(accessToken: "HELLO")
    }

}
