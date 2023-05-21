import UIKit

// TODO: not have to inherit UITableViewCell
class DateElementCell: UITableViewCell, ElementCell {

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var valueDatePicker: UIDatePicker!

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
                valueDatePicker.date = date
            } else {
                print("Could not parse date string \(stringValue) as date")
            }
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        valueDatePicker.isEnabled = !editing
    }
}
