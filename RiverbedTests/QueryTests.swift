@testable import Riverbed
import XCTest

final class QueryTests: XCTestCase {
    // MARK: - contains

    func test_contains_optionNil_matches() {
        // no constraint specified, so accept all
        let isMatch = Query.contains.match(value: .string("anything"),
                                           dataType: .text,
                                           options: Condition.Options(value: nil))
        XCTAssertTrue(isMatch)
    }

    func test_contains_optionAndValueNil_matches() {
        // no constraint specified, so accept even nothing
        let isMatch = Query.contains.match(value: nil,
                                           dataType: .text,
                                           options: Condition.Options(value: nil))
        XCTAssertTrue(isMatch)
    }

    func test_contains_valueNil_doesNotMatch() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: nil,
                                           dataType: .text,
                                           options: Condition.Options(value: "a"))
        XCTAssertFalse(isMatch)
    }

    func test_contains_equal_matches() {
        let isMatch = Query.contains.match(value: .string("abc"),
                                           dataType: .text,
                                           options: Condition.Options(value: "abc"))
        XCTAssertTrue(isMatch)
    }

    func test_contains_differentCase_matches() {
        let isMatch = Query.contains.match(value: .string("AbC"),
                                           dataType: .text,
                                           options: Condition.Options(value: "aBc"))
        XCTAssertTrue(isMatch)
    }

    func test_contains_substring_matches() {
        let isMatch = Query.contains.match(value: .string("abcd"),
                                           dataType: .text,
                                           options: Condition.Options(value: "bc"))
        XCTAssertTrue(isMatch)
    }

    func test_contains_differentStrings_doesNotMatch() {
        let isMatch = Query.contains.match(value: .string("ab"),
                                           dataType: .text,
                                           options: Condition.Options(value: "cd"))
        XCTAssertFalse(isMatch)
    }

    // MARK: - does not contain

    func test_doesNotContain_optionNil_doesNotMatch() {
        // no constraint specified, so reject none
        let isMatch = Query.doesNotContain.match(value: .string("anything"),
                                           dataType: .text,
                                           options: Condition.Options(value: nil))
        XCTAssertFalse(isMatch)
    }

    func test_doesNotContain_optionAndValueNil_doesNotMatch() {
        // no constraint specified, so do not reject even nothing
        let isMatch = Query.doesNotContain.match(value: nil,
                                           dataType: .text,
                                           options: Condition.Options(value: nil))
        XCTAssertFalse(isMatch)
    }

    func test_doesNotContain_valueNil_matches() {
        // there is a constraint and no value, so it does not contain it
        let isMatch = Query.doesNotContain.match(value: nil,
                                           dataType: .text,
                                           options: Condition.Options(value: "a"))
        XCTAssertTrue(isMatch)
    }

    func test_doesNotContain_equal_doesNotMatch() {
        let isMatch = Query.doesNotContain.match(value: .string("abc"),
                                           dataType: .text,
                                           options: Condition.Options(value: "abc"))
        XCTAssertFalse(isMatch)
    }

    func test_doesNotContain_differentCase_doesNotMatch() {
        let isMatch = Query.doesNotContain.match(value: .string("AbC"),
                                           dataType: .text,
                                           options: Condition.Options(value: "aBc"))
        XCTAssertFalse(isMatch)
    }

    func test_doesNotContain_substring_doesNotMatch() {
        let isMatch = Query.doesNotContain.match(value: .string("abcd"),
                                           dataType: .text,
                                           options: Condition.Options(value: "bc"))
        XCTAssertFalse(isMatch)
    }

    func test_contains_differentStrings_matches() {
        let isMatch = Query.doesNotContain.match(value: .string("ab"),
                                           dataType: .text,
                                           options: Condition.Options(value: "cd"))
        XCTAssertTrue(isMatch)
    }

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
