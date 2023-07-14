import UIKit

protocol EditElementDelegate: AnyObject {
    func didUpdate(element: Element)
}

class EditElementNavigationController: UINavigationController {

    var attributes: Element.Attributes!
    var element: Element! {
        didSet {
            attributes = Element.Attributes.copy(from: element.attributes)

            guard let editElementVC = viewControllers.first as? EditElementViewController else {
                preconditionFailure("Expected EditColumnViewController")
            }
            editElementVC.element = element
            editElementVC.attributes = attributes
        }
    }

    var elementStore: ElementStore!

    weak var editElementDelegate: EditElementDelegate?

    // MARK: - view controller lifecycle

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let element = self.element else { return }
        elementStore.update(element, with: attributes) { [weak self] (result) in
            switch result {
            case .success:
                print("SAVED ELEMENT \(element.id)")
                self?.editElementDelegate?.didUpdate(element: element)
            case let .failure(error):
                print("Error saving card: \(String(describing: error))")
            }
        }
    }

}
