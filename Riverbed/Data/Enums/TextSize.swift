import UIKit

enum TextSize: Int, Codable, CaseIterable {
    case largest = 1
    case larger
    case large
    case small
    case smaller
    case smallest

    // TODO: figure out a cross-platform approach to these sizes
    var label: String {
        switch self {
        case .largest: return "Largest"
        case .larger: return "Larger"
        case .large: return "Large"
        case .small: return "Small"
        case .smaller: return "Smaller"
        case .smallest: return "Smallest"
        }
    }

    var textStyle: UIFont.TextStyle {
        switch self {
        case .largest: return .title1
        case .larger: return .title2
        case .large: return .title3
        case .small: return .body
        case .smaller: return .callout
        case .smallest: return .subheadline
        }
    }

    static let defaultTextSize = TextSize.small
}
