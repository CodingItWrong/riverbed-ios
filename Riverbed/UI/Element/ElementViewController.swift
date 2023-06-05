import UIKit

protocol ElementViewControllerDelegate: AnyObject {
    func elementDidUpdate(_ element: Element)
}

// TODO: delete after DynamicElementViewController is working
// keep until then in case needed
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
    @IBOutlet private var dataTypeButton: UIButton!
    @IBOutlet private var showLabelWhenReadOnlySwitch: UISwitch!
    @IBOutlet private var readOnlySwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        showLabelWhenReadOnlySwitch.addTarget(self,
                                              action: #selector(updateShowLabelWhenReadOnly(_:)),
                                              for: .valueChanged)
        readOnlySwitch.addTarget(self,
                                 action: #selector(updateReadOnly(_:)),
                                 for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    func updateUI() {
        fieldNameField.text = element.attributes.name
        showLabelWhenReadOnlySwitch.isOn = element.attributes.options?.showLabelWhenReadOnly ?? false
        readOnlySwitch.isOn = element.attributes.readOnly

        let menuItems = Element.DataType.allCases.sorted { (dataTypeA, dataTypeB) in
            dataTypeA.label < dataTypeB.label
        }.map { (dataType) in
            let state: UIMenuElement.State = dataType == attributes.dataType ? .on : .off
            return UIAction(title: dataType.label, state: state) { [weak self] _ in self?.choose(dataType: dataType) }
        }

        dataTypeButton.menu = UIMenu(children: menuItems)
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

    // MARK: - value change handlers

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == fieldNameField {
            attributes.name = fieldNameField.text
        }
    }

    func choose(dataType: Element.DataType) {
        attributes.dataType = dataType
    }

    @objc func updateShowLabelWhenReadOnly(_ sender: UISwitch) {
        var options: Element.Options! = attributes.options
        if options == nil {
            options = Element.Options()
            attributes.options = options
        }

        options.showLabelWhenReadOnly = showLabelWhenReadOnlySwitch.isOn
    }

    @objc func updateReadOnly(_ sender: UISwitch) {
        attributes.readOnly = readOnlySwitch.isOn
    }

}
