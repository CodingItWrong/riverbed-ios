import UIKit

enum ColorTheme: String, Codable, CaseIterable {
    case red
    case orange
    case yellow
    case green
    case cyan
    case blue
    case pink

    var label: String {
        switch self {
        case .red: return "Red"
        case .orange: return "Orange"
        case .yellow: return "Yellow"
        case .green: return "Green"
        case .cyan: return "Cyan"
        case .blue: return "Blue"
        case .pink: return "Pink"
        }
    }

    var uiColor: UIColor {
        // system colors adapt to dark mode
        switch self {
        case .red: return UIColor.systemRed
        case .orange: return UIColor.systemOrange
        case .yellow: return UIColor.systemYellow
        case .green: return UIColor.systemGreen
        case .cyan: return UIColor.systemCyan
        case .blue: return UIColor.systemBlue
        case .pink: return UIColor.systemPink
        }
    }

    static var defaultUIColor = UIColor.systemPurple
}
