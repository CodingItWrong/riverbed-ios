import UIKit

protocol CardViewControllerDelegate: AnyObject {
    func cardDidUpdate(_ card: Card)
    func cardWasDeleted(_ card: Card)
}

class CardViewController: UITableViewController, ElementCellDelegate {

    @IBOutlet private var addElementButton: UIButton!

    weak var delegate: CardViewControllerDelegate?
    private var isCardDeleted = false

    var cardStore: CardStore!
    var elementStore: ElementStore!

    var board: Board!
    var elements = [Element]() {
        didSet {
            updateElementsToShow()
        }
    }
    var card: Card! { // will always be set in segue
        didSet {
            loadFieldValues()
        }
    }
    var fieldValues = [String: FieldValue?]()

    func loadFieldValues() {
        // get latest values from server in case it's changed from the list view
        cardStore.find(card.id) { [weak self] (result) in
            switch result {
            case let .success(updatedCard):
                guard let self = self else { return }
                self.fieldValues = updatedCard.attributes.fieldValues
                self.updateElementsToShow()
                self.tableView.reloadData()
            case let .failure(error):
                print("Error loading card: \(String(describing: error))")
            }
        }
        fieldValues = card.attributes.fieldValues
        updateElementsToShow()
    }

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

    override func viewDidLoad() {
        super.viewDidLoad()
        addElementButton.menu = UIMenu(children: [
            UIAction(title: "Add Field") { [weak self] _ in self?.addElement(of: .field) },
            UIAction(title: "Add Button") { [weak self] _ in self?.addElement(of: .button) },
            UIAction(title: "Add Button Menu") { [weak self] _ in self?.addElement(of: .buttonMenu) }
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isCardDeleted {
            delegate?.cardWasDeleted(card)
        } else {
            print("saving card with values \(String(describing: fieldValues))")

            // capture card and delegate to attempt to make it less likely that delegate won't be called
            guard let card = self.card else { return }
            let delegate = self.delegate

            cardStore.update(card, with: fieldValues) { (result) in
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
        cell.update(for: element, allElements: elements, fieldValues: fieldValues)
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
            addElementButton.isHidden = true
            sender.setImage(UIImage(systemName: "wrench"), for: .normal)
            sender.accessibilityLabel = "Edit Elements"
        } else {
            setEditing(true, animated: true)
            addElementButton.isHidden = false
            sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
            sender.accessibilityLabel = "Finish Editing Elements"
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

        // move in UI
        let movedItem = elementsToShow[sourceIndexPath.row]
        elementsToShow.remove(at: sourceIndexPath.row)
        elementsToShow.insert(movedItem, at: destinationIndexPath.row)

        // persist to server
        elementStore.updateDisplayOrders(of: elementsToShow) { (result) in
            if case let .failure(error) = result {
                print("Error updating display orders: \(String(describing: error))")
            }
        }
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
        print("update value of \(String(describing: element.attributes.name)) to \(String(describing: value))")
        fieldValues[element.id] = value
        recomputeTableCellSizes()
    }

    func recomputeTableCellSizes() {
        // see https://stackoverflow.com/a/5659468/477480
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func update(values: [String: FieldValue?], dismiss: Bool) {
        fieldValues = values

        if dismiss {
            self.dismiss(animated: true)
        }
    }

    func addElement(of elementType: Element.ElementType) {
        elementStore.create(of: elementType, on: board) { [weak self] (result) in
            switch result {
            case let .failure(error):
                print("Error adding element: \(String(describing: error))")
            case .success:
                guard let self = self else { return }
                self.elementStore.all(for: self.board) { [weak self] (result) in
                    guard let self = self else { return }
                    switch result {
                    case let .success(elements):
                        self.elements = elements
                        self.updateElementsToShow()
                        self.tableView.reloadData()
                    case let .failure(error):
                        print("Error reloading elements: \(String(describing: error))")
                    }
                }
            }
        }
    }

    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

}
