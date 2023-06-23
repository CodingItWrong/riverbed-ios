import UIKit

enum Icon: String, Codable, CaseIterable {
    // TODO: rename keys to platform-agnostic conceptual
    case baseball
    case bed
    case book
    case chart
    case checkbox
    case food
    case gamepad
    case link
    case mapMarker = "map-marker"
    case medicalBag = "medical-bag"
    case scale
    case television
    case tree

    var label: String {
        switch self {
        case .baseball: return "Baseball"
        case .bed: return "Bed"
        case .book: return "Book"
        case .chart: return "Chart"
        case .checkbox: return "Checkbox"
        case .food: return "Food"
        case .gamepad: return "Gamepad"
        case .link: return "Link"
        case .mapMarker: return "Map Marker"
        case .medicalBag: return "Medical Bag"
        case .scale: return "Scale"
        case .television: return "Television"
        case .tree: return "Tree"
        }
    }

    // TODO: some of these are not in iOS 15
    var image: UIImage? {
        switch self {
        case .baseball: return UIImage(systemName: "baseball")
        case .bed: return UIImage(systemName: "bed.double")
        case .book: return UIImage(systemName: "book")
        case .chart: return UIImage(systemName: "chart.line.uptrend.xyaxis")
        case .checkbox: return UIImage(systemName: "checkmark.square")
        case .food: return UIImage(systemName: "takeoutbag.and.cup.and.straw")
        case .gamepad: return UIImage(systemName: "gamecontroller")
        case .link: return UIImage(systemName: "link")
        case .mapMarker: return UIImage(systemName: "mappin.and.ellipse")
        case .medicalBag: return UIImage(systemName: "cross.case")
        case .scale: return UIImage(systemName: "scalemass")
        case .television: return UIImage(systemName: "play.tv")
        case .tree: return UIImage(systemName: "tree")
        }
    }

    static var nilImage = UIImage(systemName: "square.dashed")!
    static var defaultBoardImage = UIImage(systemName: "rectangle.split.3x1")!
}
