import Foundation

class Action: Codable {
    var command: Command?
    var field: String?

    // TODO: handle the fact that the "value" field here is used in two different ways for the different commands
    var value: String?

    init(command: Command? = nil,
         field: String? = nil,
         value: String? = nil) {
        self.command = command
        self.field = field
        self.value = value
    }

    func call(elements: [Element], fieldValues: [String: FieldValue?]) -> [String: FieldValue?] {
        switch command {
        case .none: return fieldValues
        case .setValue:
            guard let field = field else {
                print("Field for SET VALUE command not set")
                return fieldValues
            }
            guard let fieldObject = elements.first(where: { $0.id == field }) else {
                print("Field for SET VALUE command not found")
                return fieldValues
            }
            guard let dataType = fieldObject.attributes.dataType else {
                print("Field data type for SET VALUE command not set")
                return fieldValues
            }
            guard let options = fieldObject.attributes.options else {
                print("Field options for SET VALUE command not set")
                return fieldValues
            }
            guard let value = value else {
                print("Value for SET VALUE command not set")
                return fieldValues
            }
            guard let valueObject = Value(rawValue: value) else {
                print("Invalid Value enum case for SET VALUE command: \(value)")
                return fieldValues
            }

            let concreteValue = valueObject.call(fieldDataType: dataType, options: options)
            var newFieldValues = fieldValues // arrays have value semantics, so it's copied
            newFieldValues[field] = concreteValue
            return newFieldValues
        case .addDays:
            guard let field = field else {
                print("Field for SET VALUE command not set")
                return fieldValues
            }
            guard let fieldObject = elements.first(where: { $0.id == field }) else {
                print("Field for SET VALUE command not found")
                return fieldValues
            }
            guard let value = value,
                  let numDays = Int(value) else {
                print("Invalid value for SET VALUE command: \(String(describing: value))")
                return fieldValues
            }

            var updatedValue: String!
            switch fieldObject.attributes.dataType {
            case .date:
                var startDate: Date!
                let now = Date()
                if case let .string(fieldValue) = fieldValues[field],
                   let serverDate = DateUtils.date(fromServerString: fieldValue),
                   serverDate > now {
                    startDate = serverDate
                } else {
                    startDate = now
                }
                let updatedDate = DateUtils.add(days: numDays, to: startDate)
                updatedValue = DateUtils.serverString(from: updatedDate)
            case .dateTime:
                var startDateTime: Date!
                if case let .string(fieldValue) = fieldValues[field] {
                    startDateTime = DateTimeUtils.dateTime(fromServerString: fieldValue)
                } else {
                    startDateTime = Date()
                }
                let updatedDateTime = DateUtils.add(days: numDays, to: startDateTime)
                updatedValue = DateTimeUtils.serverString(from: updatedDateTime)
            default:
                print("Invalide data type for ADD DAYS")
                return fieldValues
            }

            var newFieldValues = fieldValues // arrays have value semantics, so it's copied
            newFieldValues[field] = .string(updatedValue)
            return newFieldValues
        }
    }
}
