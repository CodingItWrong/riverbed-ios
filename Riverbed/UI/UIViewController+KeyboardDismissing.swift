import UIKit

extension UIViewController {
    @IBAction func dismissKeyboard(_ sender: Any?) {
        print("dismissKeyboard")
        view.endEditing(true)
    }
}
