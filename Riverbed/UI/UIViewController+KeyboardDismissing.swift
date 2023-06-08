import UIKit

extension UIViewController {
    @IBAction func dismissKeyboard(_ sender: Any?) {
        view.endEditing(true)
    }
}
