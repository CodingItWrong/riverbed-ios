import Foundation

class User: Codable {
    let type: String
    var id: String
    var attributes: User.Attributes

    init(id: String, attributes: User.Attributes) {
        self.type = "users"
        self.id = id
        self.attributes = attributes
    }

    class Attributes: Codable {
        var allowEmails: Bool
        var iosShareToBoard: Int?

        enum CodingKeys: String, CodingKey {
            case allowEmails = "allow-emails"
            case iosShareToBoard = "ios-share-board-id"
        }
    }
}

class NewUser: Codable {
    let type: String
    var attributes: NewUser.Attributes

    init(attributes: NewUser.Attributes) {
        self.type = "users"
        self.attributes = attributes
    }

    class Attributes: Codable {
        var email: String
        var password: String
        var allowEmails: Bool? // only optional to record that it hasn't been entered yet

        init() {
            self.email = ""
            self.password = ""
            self.allowEmails = nil
        }

        enum CodingKeys: String, CodingKey {
            case email
            case password
            case allowEmails = "allow-emails"
        }
    }
}
