import UIKit

class DateElementCell: UITableViewCell {

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var valueDatePicker: UIDatePicker!

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let dateTimeFormatter: DateFormatter = {
        // TODO: consider ISO8601DateFormatter
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()

    var formatter: DateFormatter {
        switch valueDatePicker.datePickerMode {
        case .date:
            return DateElementCell.dateFormatter
        case .dateAndTime:
            return DateElementCell.dateTimeFormatter
        default:
            preconditionFailure("Unexpected date picker mode \(valueDatePicker.datePickerMode)")
        }
    }

    func update(for element: Element, and card: Card) {
        elementLabel.text = element.attributes.name

        let value = card.attributes.fieldValues[element.id]
        if case let .string(stringValue) = value {
            if let date = formatter.date(from: stringValue) {
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
