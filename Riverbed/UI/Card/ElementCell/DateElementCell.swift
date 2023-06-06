import UIKit

class DateElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate?

    private var element: Element?

    private var showDatePicker: Bool = true {
        didSet {
            updateInputs()
        }
    }

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var noValueLabel: UILabel!
    @IBOutlet private(set) var toggleDateButton: UIButton!
    @IBOutlet private(set) var valueDatePicker: UIDatePicker! {
        didSet {
            let action = UIAction { [weak self] _ in
                self?.passUpdatedValueToDelegate()
            }
            valueDatePicker.addAction(action, for: .valueChanged)
        }
    }

    private func parseDate(from string: String) -> Date? {
        switch valueDatePicker.datePickerMode {
        case .date:
            return DateUtils.date(fromServerString: string)
        case .dateAndTime:
            return DateTimeUtils.dateTime(fromServerString: string)
        default:
            preconditionFailure("Unexpected date picker mode \(valueDatePicker.datePickerMode)")
        }
    }

    func update(for element: Element, allElements: [Element], fieldValue: FieldValue?) {
        self.element = element

        elementLabel.text = element.attributes.name

        switch element.attributes.dataType {
        case .date:
            valueDatePicker.datePickerMode = .date
        case .dateTime:
            valueDatePicker.datePickerMode = .dateAndTime
        default:
            preconditionFailure("Unexpected data type: \(String(describing: element.attributes.dataType))")
        }

        if case let .string(stringValue) = fieldValue {
            if let date = parseDate(from: stringValue) {
                valueDatePicker.date = date
                showDatePicker = true
            } else {
                print("Could not parse date string \(stringValue) as date")
                showDatePicker = false
            }
        } else {
            showDatePicker = false
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        valueDatePicker.isEnabled = !editing
    }

    @IBAction func toggleDate(_ sender: UIButton) {
        showDatePicker = !showDatePicker
        if showDatePicker {
            valueDatePicker.date = Date()
        }
        passUpdatedValueToDelegate()
    }

    func updateInputs() {
        valueDatePicker.isHidden = !showDatePicker
        noValueLabel.isHidden = showDatePicker

        let iconName = showDatePicker ? "xmark.circle" : "plus.circle"
        toggleDateButton.setImage(UIImage.init(systemName: iconName), for: .normal)
    }

    func passUpdatedValueToDelegate() {
        guard let element = element else { return }

        let date = showDatePicker ? valueDatePicker.date : nil

        let dateString: String?
        switch element.attributes.dataType {
        case .date:
            dateString = DateUtils.serverString(from: date)
        case .dateTime:
            dateString = DateTimeUtils.serverString(from: date)
        default:
            preconditionFailure("Unexpected data type: \(String(describing: element.attributes.dataType))")
        }

        let fieldValue: FieldValue? = {
            if let dateString = dateString {
                return .string(dateString)
            } else {
                return .none
            }
        }()

        delegate?.update(value: fieldValue, for: element)
    }
}
