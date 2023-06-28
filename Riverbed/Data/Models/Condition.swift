import Foundation

class Condition: Codable {
    var field: String?
    var query: Query?
    var options: Condition.Options?

    class Options: Codable {
        var value: String?

        init(value: String? = nil) {
            self.value = value
        }
    }

    init(field: String? = nil,
         query: Query? = nil,
         options: Condition.Options? = nil) {
        self.field = field
        self.query = query
        self.options = options
    }
}
