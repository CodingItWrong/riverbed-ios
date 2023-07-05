import Foundation

class Action: Codable {
    var command: Command?
    var field: String?
    var value: Value?
    var specificValue: FieldValue?

    enum CodingKeys: String, CodingKey {
        case command
        case field
        case value
        case specificValue = "specific-value"
    }

    static func copy(from old: Action) -> Action {
        return Action(command: old.command,
                      field: old.field,
                      value: old.value,
                      specificValue: old.specificValue)
    }

    init(command: Command? = nil,
         field: String? = nil,
         value: Value? = nil,
         specificValue: FieldValue? = nil) {
        self.command = command
        self.field = field
        self.value = value
        self.specificValue = specificValue
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
            guard let value = value else {
                print("Value for SET VALUE command not set")
                return fieldValues
            }

            let concreteValue = value.call(fieldDataType: dataType, specificValue: specificValue)
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
            guard case let .string(valueString) = specificValue,
                  let numDays = Int(valueString) else {
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
