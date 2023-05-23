import Foundation

class Condition: Codable {
    var field: String?
    var query: Query?
    var options: Condition.Options?

    class Options: Codable {
        var value: String?
    }
}
