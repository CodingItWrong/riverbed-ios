import UIKit

enum TextSize: String, Codable {
    case titleLarge
    case titleMedium
    case titleSmall
    case bodyLarge
    case bodyMedium
    case bodySmall

    // TODO: figure out a cross-platform approach to these sizes
    var label: String {
        switch self {
        case .titleLarge: return "Title Large"
        case .titleMedium: return "Title Medium"
        case .titleSmall: return "Title Small"
        case .bodyLarge: return "Body Large"
        case .bodyMedium: return "Body Medium"
        case .bodySmall: return "Body Small"
        }
    }

    var textStyle: UIFont.TextStyle {
        switch self {
        case .titleLarge: return .title1
        case .titleMedium: return .title2
        case .titleSmall: return .title3
        case .bodyLarge: return .body
        case .bodyMedium: return .callout
        case .bodySmall: return .subheadline
        }
    }
}
