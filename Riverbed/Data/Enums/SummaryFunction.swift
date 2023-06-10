import Foundation

enum SummaryFunction: String, Codable, CaseIterable {
    case count = "COUNT"
    case sum = "SUM"

    var label: String {
        switch self {
        case .count: return "Count"
        case .sum: return "Sum"
        }
    }

    var hasField: Bool {
        self == .sum
    }
}
