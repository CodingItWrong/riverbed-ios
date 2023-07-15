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
