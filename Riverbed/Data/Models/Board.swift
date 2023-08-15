import Foundation

class Board: Codable, Hashable, Equatable {
    let type: String
    var id: String
    var attributes: Board.Attributes

    static var defaultName: String { "(unnamed board)" }

    static func == (lhs: Board, rhs: Board) -> Bool {
        lhs.id == rhs.id
    }

    init(id: String, attributes: Board.Attributes) {
        self.type = "boards"
        self.id = id
        self.attributes = attributes
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(attributes)
    }

    class Attributes: Codable, Hashable, Equatable {
        static func == (lhs: Board.Attributes, rhs: Board.Attributes) -> Bool {
            // maybe need to add more attributes here and to hash(into:) to make equality more predictable
            lhs.name == rhs.name &&
            lhs.icon == rhs.icon &&
            lhs.colorTheme == rhs.colorTheme
        }

        var name: String?
        var icon: Icon?
        var colorTheme: ColorTheme?
        var favoritedAt: Date?
        var options: Board.Options?

        init(name: String? = nil,
             icon: Icon? = nil,
             colorTheme: ColorTheme? = nil,
             favoritedAt: Date? = nil,
             options: Options? = nil) {
            self.name = name
            self.icon = icon
            self.colorTheme = colorTheme
            self.favoritedAt = favoritedAt
            self.options = options
        }

        func hash(into hasher: inout Hasher) {
            // only the values used in board list display
            hasher.combine(name)
            hasher.combine(icon)
            hasher.combine(colorTheme)
        }

        enum CodingKeys: String, CodingKey {
            case name
            case icon
            case colorTheme = "color-theme"
            case favoritedAt = "favorited-at"
            case options
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(icon, forKey: .icon)
            try container.encode(colorTheme, forKey: .colorTheme)
            try container.encode(options, forKey: .options)

            if let favoritedAt = favoritedAt {
                try container.encode(favoritedAt, forKey: .favoritedAt)
            } else {
                try container.encodeNil(forKey: .favoritedAt)
            }
        }
    }

    class Options: Codable {
        var webhooks: Webhooks?
        var share: Share?
    }

    class Webhooks: Codable {
        var cardCreate: String?
        var cardUpdate: String?

        enum CodingKeys: String, CodingKey {
            case cardCreate = "card-create"
            case cardUpdate = "card-update"
        }
    }

    class Share: Codable {
        var urlField: String?
        var titleField: String?

        enum CodingKeys: String, CodingKey {
            case urlField = "url-field"
            case titleField = "title-field"
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
