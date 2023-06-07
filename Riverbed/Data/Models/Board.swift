import Foundation

class Board: Codable {
    let type: String
    var id: String
    var attributes: Board.Attributes

    static var defaultName: String { "(unnamed board)" }

    init(id: String, attributes: Board.Attributes) {
        self.type = "boards"
        self.id = id
        self.attributes = attributes
    }

    class Attributes: Codable {
        var name: String?
        var icon: Icon?
        var colorTheme: ColorTheme?
        var favoritedAt: Date?

        init(name: String? = nil,
             icon: Icon? = nil,
             colorTheme: ColorTheme? = nil,
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

class NewBoard: Codable {
    let type: String
    var attributes: Board.Attributes

    init(attributes: Board.Attributes) {
        self.type = "boards"
        self.attributes = attributes
    }
}
