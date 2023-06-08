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
