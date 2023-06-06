import Foundation

enum Value: String, Codable, CaseIterable {
    case empty = "empty"
    case now = "now"
    case specificValue = "specific_value"

    var label: String {
        switch self {
        case .empty: return "empty"
        case .now: return "now"
        case .specificValue: return "specific value"
        }
    }

    var usesConcreteValue: Bool {
        self == .specificValue
    }

    func call(fieldDataType: Element.DataType, options: Element.Options?) -> FieldValue? {
        switch self {
        case .empty: return .none
        case .now:
            let now = Date()
            switch fieldDataType {
            case .date:
                if let dateString = DateUtils.serverString(from: now) {
                    return .string(dateString)
                } else {
                    return nil
                }
            case .dateTime:
                if let dateString = DateTimeUtils.serverString(from: now) {
                    return .string(dateString)
                } else {
                    return nil
                }
            case .text:
                if let dateString = DateTimeUtils.humanString(from: now) {
                    return .string(dateString)
                } else {
                    return nil
                }
            default:
                print("Value.now is not valid for data type \(String(describing: fieldDataType))")
                return nil
            }
        case .specificValue:
            return options?.initialSpecificValue
        }
    }
}
