import UIKit

protocol CardViewControllerDelegate: AnyObject {
    func cardDidUpdate(_ card: Card)
    func cardWasDeleted(_ card: Card)
}

class CardViewController: UITableViewController, ElementCellDelegate {
    weak var delegate: CardViewControllerDelegate?
    private var isCardDeleted = false

    var cardStore: CardStore!

    var elements = [Element]() {
        didSet {
            updateElementsToShow()
        }
    }
    var card: Card! { // will always be set in segue
        didSet {
            fieldValues = card.attributes.fieldValues
            updateElementsToShow()
        }
    }
    var fieldValues = [String: FieldValue?]()

    var elementsToShow = [Element]()

    func updateElementsToShow() {
        guard let card = card else { return }

        let filteredElements = elements.filter { (element) in
            if let showConditions = element.attributes.showConditions {
                return checkConditions(fieldValues: card.attributes.fieldValues,
                                       conditions: showConditions,
                                       elements: elements)
            } else {
                return true
            }
        }
        elementsToShow = filteredElements.sorted(by: Element.areInIncreasingOrder(lhs:rhs:))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isCardDeleted {
            delegate?.cardWasDeleted(card)
        } else {
            cardStore.update(card, with: fieldValues) { [weak self] (result) in
                guard let self = self else { return }

                switch result {
                case .success:
                    print("SAVED CARD \(card.id)")
                    delegate?.cardDidUpdate(card)
                case let .failure(error):
                    print("Error saving card: \(String(describing: error))")
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elementsToShow.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = elementsToShow[indexPath.row]
        let cellType = cellType(for: element)
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: cellType),
            for: indexPath) as? ElementCell
        else { preconditionFailure("Expected a \(String(describing: cellType))") }
        cell.delegate = self
        cell.update(for: element, and: card, allElements: elements)
        return cell
    }

    private func cellType(for element: Element) -> UITableViewCell.Type {
        if element.attributes.readOnly {
            return ReadOnlyElementCell.self
        }

        switch element.attributes.elementType {
        case .button: return ButtonElementCell.self
        case .buttonMenu: return ButtonMenuElementCell.self
        case .field:
            switch element.attributes.dataType {
            case .choice: return ChoiceElementCell.self
            case .date: return DateElementCell.self
            case .dateTime: return DateElementCell.self
            case .geolocation: return GeolocationElementCell.self
            case .number: return TextElementCell.self
            case .text: return TextElementCell.self
            case .none: return TextElementCell.self
            }
        }
    }

    @IBAction func toggleEditing(_ sender: UIButton) {
        // TODO: voiceover
        if isEditing {
            setEditing(false, animated: true)
            sender.setImage(UIImage(systemName: "wrench"), for: .normal)
        } else {
            setEditing(true, animated: true)
            sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
        }
    }

    @IBAction func deleteCard(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete?",
                                      message: "Are you sure you want to delete this card?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Delete",
                                      style: .destructive) {[weak self] _ in
            guard let self = self else { return }

            cardStore.delete(card) { [weak self] (result) in
                switch result {
                case .success:
                    self?.isCardDeleted = true
                    self?.dismiss(animated: true)
                case let .failure(error):
                    print("Error deleting card: \(String(describing: error))")
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        if sourceIndexPath == destinationIndexPath {
            return
        }

        // TODO: need to persist the new order to the server and resort from it
        let movedItem = elements[sourceIndexPath.row]
        elements.remove(at: sourceIndexPath.row)
        elements.insert(movedItem, at: destinationIndexPath.row)
    }

    override func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        } else {
            return .none // disable swipe-to-delete when not in editing mode
        }
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            elements.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func update(value: FieldValue?, for element: Element) {
        fieldValues[element.id] = value
        print("UPDATED \(String(describing: element.attributes.name)) to \(String(describing: value))")
    }

    func update(values: [String: FieldValue?], dismiss: Bool) {
        fieldValues = values

        if dismiss {
            self.dismiss(animated: true)
        }
    }

    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

}
