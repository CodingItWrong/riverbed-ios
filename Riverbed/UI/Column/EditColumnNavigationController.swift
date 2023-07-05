import UIKit

protocol EditColumnDelegate: AnyObject {
    func didUpdate(_ column: Column)
}

class EditColumnNavigationController: UINavigationController {

    var attributes: Column.Attributes! {
        didSet {
            guard let editColumnVC = viewControllers.first as? EditColumnViewController else {
                preconditionFailure("Expected EditColumnViewController")
            }
            editColumnVC.attributes = attributes
        }
    }
    var column: Column! {
        didSet {
            attributes = Column.Attributes.copy(from: column.attributes)
        }
    }

    var columnStore: ColumnStore!

    weak var editColumnDelegate: EditColumnDelegate?

    // MARK: - view controller lifecycle

    // Needed so that no matter which VC is showing within the nav controller, we save upon dismiss
    override func viewWillDisappear(_ animated: Bool) {
        // note that this runs both when the modal is dismissed and when pushing a VC on the navigation stack
        super.viewWillDisappear(animated)

        guard let column = column else { return }
        let attributesChanged = attributes != column.attributes

        if attributesChanged {
            columnStore.update(column, with: attributes) { [weak self] (result) in
                switch result {
                case .success:
                    print("SAVED COLUMN \(column.id)")
                    self?.editColumnDelegate?.didUpdate(column)
                case let .failure(error):
                    print("Error saving column: \(String(describing: error))")
                }
            }
        }
    }

}
