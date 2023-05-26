import UIKit

// TODO: not have to inherit UITableViewCell
class DateElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate?

    private var dateValue: Date? {
        didSet {
            updateInputs()
        }
    }

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var valueDatePicker: UIDatePicker!
    @IBOutlet private(set) var noValueLabel: UILabel!
    @IBOutlet private(set) var toggleDateButton: UIButton!

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

    func update(for element: Element, and card: Card) {
        elementLabel.text = element.attributes.name

        switch element.attributes.dataType {
        case .date:
            valueDatePicker.datePickerMode = .date
        case .dateTime:
            valueDatePicker.datePickerMode = .dateAndTime
        default:
            // TODO: remove this when all cases covered
            valueDatePicker.datePickerMode = .date
        }

        let value = card.attributes.fieldValues[element.id]
        if case let .string(stringValue) = value {
            if let date = parseDate(from: stringValue) {
                dateValue = date
            } else {
                print("Could not parse date string \(stringValue) as date")
                dateValue = nil
            }
        } else {
            dateValue = nil
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        valueDatePicker.isEnabled = !editing
    }

    @IBAction func toggleDate(_ sender: UIButton) {
        if dateValue == nil {
            dateValue = Date()
        } else {
            dateValue = nil
        }
    }

    func updateInputs() {
        if let dateValue = dateValue {
            valueDatePicker.date = dateValue
            valueDatePicker.isHidden = false
            noValueLabel.isHidden = true
            toggleDateButton.setImage(UIImage.init(systemName: "xmark.circle"), for: .normal)
        } else {
            valueDatePicker.isHidden = true
            noValueLabel.isHidden = false
            toggleDateButton.setImage(UIImage.init(systemName: "plus.circle"), for: .normal)
        }
    }
}
