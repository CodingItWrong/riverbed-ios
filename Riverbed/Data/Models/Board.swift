import Foundation

class Board: Codable {
    let type: String
    var id: String
    var attributes: BoardAttributes

    init(id: String, attributes: BoardAttributes) {
        self.type = "cards"
        self.id = id
        self.attributes = attributes
    }
}

class BoardAttributes: Codable {
    var name: String
    var icon: String?
    var colorTheme: String?
    var favoritedAt: Date?

    enum CodingKeys: String, CodingKey {
        case name
        case icon
        case colorTheme = "color_theme"
        case favoritedAt = "favorited_at"
    }
}
