import Foundation

class Board: Codable {
    let type: String
    var id: String
    var attributes: Board.Attributes

    init(id: String, attributes: Board.Attributes) {
        self.type = "boards"
        self.id = id
        self.attributes = attributes
    }

    class Attributes: Codable {
        var name: String
        var icon: String?
        var colorTheme: String?
        var favoritedAt: Date?

        init(name: String,
             icon: String? = nil,
             colorTheme: String? = nil,
             favoritedAt: Date? = nil) {
            self.name = name
            self.icon = icon
            self.colorTheme = colorTheme
            self.favoritedAt = favoritedAt
        }

        enum CodingKeys: String, CodingKey {
            case name
            case icon
            case colorTheme = "color-theme"
            case favoritedAt = "favorited-at"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(icon, forKey: .icon)
            try container.encode(colorTheme, forKey: .colorTheme)

            if let favoritedAt = favoritedAt {
                try container.encode(favoritedAt, forKey: .favoritedAt)
            } else {
                try container.encodeNil(forKey: .favoritedAt)
            }
        }
    }
}
