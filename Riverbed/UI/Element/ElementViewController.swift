import UIKit

protocol ElementViewControllerDelegate: AnyObject {
    func elementDidUpdate(_ element: Element)
}

class ElementViewController: UITableViewController,
                             UITextFieldDelegate {

    var elementStore: ElementStore!
    weak var delegate: ElementViewControllerDelegate?

    var attributes: Element.Attributes!
    var element: Element! {
        didSet {
            attributes = element.attributes
        }
    }

    @IBOutlet private var fieldNameField: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    func updateUI() {
        fieldNameField.text = element.attributes.name
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

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == fieldNameField {
            attributes.name = fieldNameField.text
        }
    }

}
