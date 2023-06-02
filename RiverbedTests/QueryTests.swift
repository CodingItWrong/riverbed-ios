@testable import Riverbed
import XCTest

final class QueryTests: XCTestCase {
    // MARK: - does not equal

    func test_match_doesNotEqual_bothNil_doesNotMatch() {
        let isMatch = Query.doesNotEqual.match(value: nil,
                                               dataType: .text,
                                               options: Condition.Options(value: nil))

        XCTAssertFalse(isMatch)
    }

    func test_match_doesNotEqual_onlyOptionNil_matches() {
        let isMatch = Query.doesNotEqual.match(value: .string("hello"),
                                               dataType: .text,
                                               options: Condition.Options(value: nil))

        XCTAssertTrue(isMatch)
    }

    func test_match_doesNotEqual_onlyValueNil_matches() {
        let isMatch = Query.doesNotEqual.match(value: nil,
                                               dataType: .text,
                                               options: Condition.Options(value: "hello"))

        XCTAssertTrue(isMatch)
    }

    func test_match_doesNotEqual_differentStrings_matches() {
        let isMatch = Query.doesNotEqual.match(value: .string("a"),
                                               dataType: .text,
                                               options: Condition.Options(value: "b"))

        XCTAssertTrue(isMatch)
    }

    func test_match_doesNotEqual_differentCase_matches() {
        let isMatch = Query.doesNotEqual.match(value: .string("a"),
                                               dataType: .text,
                                               options: Condition.Options(value: "A"))

        XCTAssertTrue(isMatch)
    }

    // MARK: - equals

    func test_match_equals_bothNil_matches() {
        let isMatch = Query.equals.match(value: nil,
                                         dataType: .text,
                                         options: Condition.Options(value: nil))

        XCTAssertTrue(isMatch)
    }

    func test_match_equals_onlyOptionNil_doesNotMatch() {
        let isMatch = Query.equals.match(value: .string("hello"),
                                         dataType: .text,
                                         options: Condition.Options(value: nil))

        XCTAssertFalse(isMatch)
    }

    func test_match_equals_onlyValueNil_doesNotMatch() {
        let isMatch = Query.equals.match(value: nil,
                                         dataType: .text,
                                         options: Condition.Options(value: "hello"))

        XCTAssertFalse(isMatch)
    }

    func test_match_equals_differentStrings_doesNotMatch() {
        let isMatch = Query.equals.match(value: .string("a"),
                                         dataType: .text,
                                         options: Condition.Options(value: "b"))

        XCTAssertFalse(isMatch)
    }

    func test_match_equals_sameString_matches() {
        let isMatch = Query.equals.match(value: .string("a"),
                                         dataType: .text,
                                         options: Condition.Options(value: "a"))

        XCTAssertTrue(isMatch)
    }

    func test_match_equals_differentCase_doesNotMatch() {
        let isMatch = Query.equals.match(value: .string("a"),
                                         dataType: .text,
                                         options: Condition.Options(value: "A"))

        XCTAssertFalse(isMatch)
    }
}
