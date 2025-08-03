import UIKit

protocol CardViewControllerDelegate: AnyObject {
    func didUpdate(card: Card)
    func didUpdateElements(forCard card: Card)
    func didDelete(card: Card)
}

class CardViewController: UITableViewController,
                          ElementCellDelegate,
                          EditElementDelegate {

    @IBOutlet private var tapGestureRecognizer: UIGestureRecognizer!
    
    @IBOutlet private var addElementButton: UIButton! {
        didSet {
            if #available(iOS 26, *) {
                addElementButton.configuration = .glass()
                addElementButton.configuration?.image = UIImage(systemName: "plus")
            }
        }
    }
    
    @IBOutlet private var beginEditingButton: UIButton! {
        didSet {
            if #available(iOS 26, *) {
                beginEditingButton.configuration = .glass()
                beginEditingButton.configuration?.image = UIImage(systemName: "wrench")
            }
        }
    }

    @IBOutlet private var endEditingButton: UIButton! {
        didSet {
            if #available(iOS 26, *) {
                endEditingButton.configuration = .prominentGlass()
                endEditingButton.configuration?.image = UIImage(systemName: "checkmark")
            }
        }
    }

    @IBOutlet private var deleteButton: UIButton! {
        didSet {
            if #available(iOS 26, *) {
                deleteButton.configuration = .prominentGlass()
                deleteButton.configuration?.image = UIImage(systemName: "trash")
            }
        }
    }
    
    @IBOutlet private var instructionLabel: UILabel! {
        didSet {
            instructionLabel.text = nil
        }
    }

    weak var delegate: CardViewControllerDelegate?
    private var isCardDeleted = false

    var cardStore: CardStore!
    var elementStore: ElementStore!

    var board: Board!
    var elements = [Element]() {
        didSet {
            updateSortedElements()
            updateInstructionLabel()
        }
    }
    var card: Card! { // will always be set in segue
        didSet {
            loadFieldValues()
        }
    }
    var originalFieldValues = [String: FieldValue?]()
    var fieldValues = [String: FieldValue?]()

    func loadFieldValues() {
        // get latest values from server in case it's changed from the list view
        cardStore.find(card.id) { [weak self] (result) in
            switch result {
            case let .success(updatedCard):
                guard let self = self else { return }
                self.originalFieldValues = updatedCard.attributes.fieldValues
                self.fieldValues = updatedCard.attributes.fieldValues
                self.updateElementsToShow()
                self.tableView.reloadData()
            case let .failure(error):
                print("Error loading card: \(String(describing: error))")
            }
        }

        // TODO: do we still want to set this immediately in addition to from the server?
        originalFieldValues = card.attributes.fieldValues
        fieldValues = card.attributes.fieldValues
        updateElementsToShow()
    }

    var sortedElements = [Element]()
    var elementsToShow = [Element]()

    func updateSortedElements() {
        sortedElements = elements.inDisplayOrder
        updateElementsToShow()
    }

    func updateElementsToShow() {
        guard let card = card else { return }

        elementsToShow = sortedElements.filter { (element) in
            if let showConditions = element.attributes.showConditions {
                return checkConditions(fieldValues: card.attributes.fieldValues,
                                       conditions: showConditions,
                                       elements: elements)
            } else {
                return true
            }
        }
    }

    func updateInstructionLabel() {
        if elements.isEmpty {
            instructionLabel?.text = "Add a field by clicking the wrench, then the plus, then \"Add Field\"."
        } else {
            instructionLabel?.text = nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = true
        updateInstructionLabel()

        let actions = Element.ElementType.allCases.map { (elementType) in
            UIAction(title: "New \(elementType.label)", image: UIImage(systemName: "plus.square")) { [weak self] _ in
                self?.addElement(of: elementType)
            }
        }
        addElementButton.menu = UIMenu(children: actions)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deleteButton.tintColor = .systemRed
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let isCardChanged = fieldValues != originalFieldValues

        if isCardDeleted {
            delegate?.didDelete(card: card)
        } else if isCardChanged {
            print("saving card with values \(String(describing: fieldValues))")

            // capture card and delegate to attempt to make it less likely that delegate won't be called
            guard let card = self.card else { return }
            let delegate = self.delegate

            cardStore.update(card, with: fieldValues) { (result) in
                switch result {
                case .success:
                    print("SAVED CARD \(card.id)")
                    delegate?.didUpdate(card: card)
                case let .failure(error):
                    print("Error saving card: \(String(describing: error))")
                }
            }
        }
    }

    private func cellType(for element: Element) -> UITableViewCell.Type {
        if element.attributes.readOnly {
            return ReadOnlyElementCell.self
        } else {
            return elementCellType(for: element.attributes)
        }
    }

    @IBAction func beginEditing(_ sender: UIButton) {
        setEditing(true, animated: true)
        updateForEditingState()
    }

    
    @IBAction func endEditing(_ sender: UIButton) {
        setEditing(false, animated: true)
        updateForEditingState()
    }
    
    func updateForEditingState() {
        beginEditingButton.isHidden = isEditing
        deleteButton.isHidden = isEditing
        
        addElementButton.isHidden = !isEditing
        endEditingButton.isHidden = !isEditing


        // TODO: voiceover
        if isEditing {
            tapGestureRecognizer.cancelsTouchesInView = false // allows tapping fields to edit them
        } else {
            tapGestureRecognizer.cancelsTouchesInView = true // allows dismissing autocorrect popup
        }
        tableView.reloadData() // because editing shows all elements

    }

    @objc func dismissVC(_ sender: Any?) {
        dismiss(animated: true)
    }

    func recomputeTableCellSizes() {
        // see https://stackoverflow.com/a/5659468/477480
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    // MARK: - actions

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(addField(_:)) || action == #selector(addButton(_:)) || action == #selector(addButtonMenu(_:)) {
            return isEditing
        } else {
            return true
        }
    }
    
    @objc func addField(_ sender: Any?) {
        addElement(of: .field)
    }

    @objc func addButton(_ sender: Any?) {
        addElement(of: .button)
    }

    @objc func addButtonMenu(_ sender: Any?) {
        addElement(of: .buttonMenu)
    }

    func addElement(of elementType: Element.ElementType) {
        elementStore.create(of: elementType, on: board) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case let .success(element):
                self.reloadElements()
                self.goTo(element: element)
            case let .failure(error):
                print("Error adding element: \(String(describing: error))")
                self.showAlert(withErrorMessage:
                    "An error occurred while adding the \(elementType.label.lowercased()).")
            }
        }
    }

    func reloadElements() {
        elementStore.all(for: board) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case let .success(elements):
                self.elements = elements
                self.updateSortedElements()
                self.tableView.reloadData()
            case let .failure(error):
                print("Error reloading elements: \(String(describing: error))")
            }
        }
    }

    @IBAction func deleteCard(_ sender: Any?) {
        let alert = UIAlertController(title: "Delete?",
                                      message: "Are you sure you want to delete this card?",
                                      preferredStyle: .alert)
        if #available(iOS 16, *) {
            // should display from button on iOS 26, but doesn't seem to
            alert.popoverPresentationController?.sourceItem = deleteButton
        }

        // .destructive does not bind to Return key on macOS even when preferredAction
//        let deleteActionStyle: UIAlertAction.Style = .default

        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .destructive) {[weak self] _ in
               guard let self = self else { return }

               cardStore.delete(card) { [weak self] (result) in
                   guard let self = self else { return }
                   switch result {
                   case .success:
                       self.isCardDeleted = true
                       self.dismiss(animated: true)
                   case let .failure(error):
                       print("Error deleting card: \(String(describing: error))")
                       self.showAlert(withErrorMessage: "An error occurred while deleting the card.")
                   }
               }
           }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.preferredAction = deleteAction

        present(alert, animated: true)
    }

    func goTo(element: Element) {
        performSegue(withIdentifier: "editElement", sender: element)
    }

    func showAlert(withErrorMessage errorMessage: String) {
        let alert = UIAlertController(title: "Error",
                                      message: errorMessage,
                                      preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        alert.preferredAction = okAction
        present(alert, animated: true)
    }

    // MARK: - table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (isEditing ? sortedElements : elementsToShow).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = (isEditing ? sortedElements : elementsToShow)[indexPath.row]

        let cellType = cellType(for: element)
        guard let cell = tableView.dequeueOrRegisterReusableCell(
            withIdentifier: String(describing: cellType)) as? ElementCell
        else { preconditionFailure("Expected a \(String(describing: cellType))") }
        cell.delegate = self
        let fieldValue = singularizeOptionality(fieldValues[element.id])
        cell.update(for: element, allElements: elements, fieldValue: fieldValue)
        return cell
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // macOS allows drag-to-reorder when not in editing mode.
        // This overrides it so we can only drag rows when editing.
        isEditing
    }

    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        if sourceIndexPath == destinationIndexPath {
            return
        }

        // move in UI
        let movedItem = sortedElements[sourceIndexPath.row]
        sortedElements.remove(at: sourceIndexPath.row)
        sortedElements.insert(movedItem, at: destinationIndexPath.row)
        updateElementsToShow()

        // persist to server
        elementStore.updateDisplayOrders(of: sortedElements) { (result) in
            if case let .failure(error) = result {
                print("Error updating display orders: \(String(describing: error))")
            }
        }
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let element = sortedElements[indexPath.row]
        goTo(element: element)
        tableView.deselectRow(at: indexPath, animated: true)
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
            let element = sortedElements[indexPath.row]
            elementStore.delete(element) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success:
                    elements.remove(at: indexPath.row)
                    updateSortedElements()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                case let .failure(error):
                    print("Error deleting element: \(String(describing: error))")
                    self.showAlert(withErrorMessage:
                        "An error occurred while deleting the \(element.attributes.elementType.label.lowercased()).")
                }
            }
        }
    }

    // MARK: - app-specific delegates

    func didUpdate(element: Element) {
        // maybe just do that when this VC dismisses, instead of automatically propagating
        reloadElements()
        delegate?.didUpdateElements(forCard: card)
    }

    func update(value: FieldValue?, for element: Element) {
        // avoid creating a new instance if not needed, to preserve value equality
        if fieldValues[element.id] != value {
            if case let .string(stringValue) = value,
               stringValue == "" {
                fieldValues[element.id] = nil
            } else {
                fieldValues[element.id] = value
            }
        }

        recomputeTableCellSizes()
    }

    func update(values: [String: FieldValue?], dismiss: Bool) {
        fieldValues = values

        if dismiss {
            self.dismiss(animated: true)
        }
    }

    // MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        segue.destination.view.tintColor = view.tintColor

        switch segue.identifier {
        case "editElement":
            guard let element = sender as? Element else { preconditionFailure("Expected an Elmement") }
            guard let navigationVC = segue.destination as? EditElementNavigationController else {
                preconditionFailure("Expected EditElementNavigationController")
            }
            guard let elementVC = navigationVC.viewControllers.first as? EditElementViewController else {
                preconditionFailure("Expected EditColumnViewController")
            }

            navigationVC.element = element
            navigationVC.elementStore = elementStore
            navigationVC.editElementDelegate = self

            elementVC.elements = elements
        case "test":
            print("test")
        default:
            preconditionFailure("Unexpected segue")
        }
    }

}
