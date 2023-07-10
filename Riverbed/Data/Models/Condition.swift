import Foundation

class Condition: Codable, Equatable {
    var field: String?
    var query: Query?
    var options: Condition.Options?

    static func copy(from old: Condition) -> Condition {
        Condition(field: old.field,
                  query: old.query,
                  options: Options.copy(from: old.options))
    }

    static func == (lhs: Condition, rhs: Condition) -> Bool {
        lhs.field == rhs.field &&
        lhs.query == rhs.query &&
        lhs.options == rhs.options
    }

    init(field: String? = nil,
         query: Query? = nil,
         options: Condition.Options? = nil) {
        self.field = field
        self.query = query
        self.options = options
    }

    class Options: Codable, Equatable {
        var value: FieldValue?

        static func copy(from old: Options?) -> Options? {
            guard let old = old else { return nil }
            return Options(value: old.value)
        }

        static func == (lhs: Condition.Options, rhs: Condition.Options) -> Bool {
            lhs.value == rhs.value
        }

        init(value: FieldValue? = nil) {
            self.value = value
        }
    }
}
