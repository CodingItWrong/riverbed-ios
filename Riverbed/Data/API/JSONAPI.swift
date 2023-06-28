import Foundation

struct JSONAPI {
    // TODO: there is probably a better name for the thing that *contains* the data; check the spec
    class Data<T: Codable>: Codable {
        var data: T

        init(data: T) {
            self.data = data
        }
    }

    class ResourceIdentifier: Codable {
        var type: String
        var id: String

        init(type: String, id: String) {
            self.type = type
            self.id = id
        }
    }
}
