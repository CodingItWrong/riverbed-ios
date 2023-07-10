import Foundation

enum Query: String, Codable, CaseIterable {
    case contains = "CONTAINS"
    case doesNotContain = "DOES_NOT_CONTAIN"
    case doesNotEqual = "DOES_NOT_EQUAL_VALUE"
    case equals = "EQUALS_VALUE"
    case isCurrentMonth = "IS_CURRENT_MONTH"
    case isEmpty = "IS_EMPTY"
    case isEmptyOrEquals = "IS_EMPTY_OR_EQUALS"
    case isFuture = "IS_FUTURE"
    case isNotCurrentMonth = "IS_NOT_CURRENT_MONTH"
    case isNotEmpty = "IS_NOT_EMPTY"
    case isNotFuture = "IS_NOT_FUTURE"
    case isNotPast = "IS_NOT_PAST"
    case isPast = "IS_PAST"
    case isPreviousMonth = "IS_PREVIOUS_MONTH"

    var label: String {
        switch self {
        case .contains: return "contains"
        case .doesNotContain: return "does not contain"
        case .doesNotEqual: return "does not equal"
        case .equals: return "equals"
        case .isCurrentMonth: return "current month"
        case .isEmpty: return "empty"
        case .isEmptyOrEquals: return "empty or equals"
        case .isFuture: return "future"
        case .isNotCurrentMonth: return "not current month"
        case .isNotEmpty: return "not empty"
        case .isNotFuture: return "not future"
        case .isNotPast: return "not past"
        case .isPast: return "past"
        case .isPreviousMonth: return "previous month"
        }
    }

    var showConcreteValueField: Bool {
        switch self {
        case .contains, .doesNotContain, .doesNotEqual, .equals, .isEmptyOrEquals: return true
        default: return false
        }
    }

    func match(value: FieldValue?, dataType: Element.DataType, options: Condition.Options?) -> Bool {
        switch self {
        case .contains:
            guard let optionValue = options?.value else { return true }
            guard let value = value else { return false }
            if dataType == .choice {
                return value == optionValue
            }

            if case let .string(stringValue) = value,
               case let .string(optionStringValue) = optionValue {
                return stringValue.lowercased().contains(optionStringValue.lowercased())
            } else {
                return false
            }
        case .doesNotContain:
            return !Query.contains.match(value: value, dataType: dataType, options: options)
        case .doesNotEqual:
            return !Query.equals.match(value: value, dataType: dataType, options: options)
        case .equals:
            if value == nil && options?.value == nil { return true }
            if case let .string(stringValue) = value,
               case let .string(optionStringValue) = options?.value {
                return stringValue == optionStringValue
            } else if case let .dictionary(dictionaryValue) = value,
                      case let .dictionary(optionDictionaryValue) = options?.value {
                return dictionaryValue == optionDictionaryValue
            } else {
                return false
            }
        case .isCurrentMonth:
            guard case let .string(value) = value else {
                return false
            }
            switch dataType {
            case .date:
                return DateUtils.isCurrentMonth(value)
            case .dateTime:
                return DateTimeUtils.isCurrentMonth(value)
            default:
                return false
            }
        case .isEmpty:
            switch value {
            case let .string(stringValue): return stringValue == ""
            case .none: return true
            default: return false
            }
        case .isEmptyOrEquals:
            return Query.isEmpty.match(value: value, dataType: dataType, options: options) ||
                   Query.equals.match(value: value, dataType: dataType, options: options)
        case .isFuture:
            guard case let .string(dateString) = value else {
                return false
            }
            switch dataType {
            case .date:
                guard let date = DateUtils.date(fromServerString: dateString) else {
                    return false
                }
                return date > Date()
            case .dateTime:
                guard let date = DateTimeUtils.dateTime(fromServerString: dateString) else {
                    return false
                }
                return date > Date()
            default:
                return false
            }
        case .isNotCurrentMonth:
            return !Query.isCurrentMonth.match(value: value, dataType: dataType, options: options)
        case .isNotEmpty:
            return !Query.isEmpty.match(value: value, dataType: dataType, options: options)
        case .isNotFuture:
            return !Query.isFuture.match(value: value, dataType: dataType, options: options)
        case .isNotPast:
            return !Query.isPast.match(value: value, dataType: dataType, options: options)
        case .isPast:
            guard case let .string(dateString) = value else {
                return false
            }
            switch dataType {
            case .date:
                guard let date = DateUtils.date(fromServerString: dateString) else {
                    return false
                }
                return date < Date()
            case .dateTime:
                guard let date = DateTimeUtils.dateTime(fromServerString: dateString) else {
                    return false
                }
                return date < Date()
            default:
                return false
            }
        case .isPreviousMonth:
            guard case let .string(dateString) = value else {
                return false
            }
            switch dataType {
            case .date:
                return DateUtils.isMonthOffset(dateString, by: -1)
            case .dateTime:
                return DateTimeUtils.isMonthOffset(dateString, by: -1)
            default:
                return false
            }
        }
    }
}
