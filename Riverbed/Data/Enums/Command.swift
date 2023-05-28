import Foundation

enum Command: String, Codable {
    case addDays = "ADD_DAYS"
    case setValue = "SET_VALUE"

    var label: String {
        switch self {
        case .addDays: return "Add Days"
        case .setValue: return "Set Value"
        }
    }
}
