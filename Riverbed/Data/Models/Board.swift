import Foundation

class Board: Codable {
    let type: String
    var id: String
    var attributes: Board.Attributes

    init(id: String, attributes: Board.Attributes) {
        self.type = "cards"
        self.id = id
        self.attributes = attributes
    }

    class Attributes: Codable {
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
}
