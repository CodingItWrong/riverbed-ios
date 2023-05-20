import UIKit

class DateElementCell: UITableViewCell {

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var valueDatePicker: UIDatePicker!

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func update(for element: Element, and card: Card) {
        elementLabel.text = element.attributes.name

        let value = card.attributes.fieldValues[element.id]
        if case let .string(stringValue) = value {
            if let date = DateElementCell.dateFormatter.date(from: stringValue) {
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
