@testable import Riverbed
import XCTest

final class QueryTests: XCTestCase {
    var dataType: Element.DataType!
    var options: Condition.Options!
    var value: FieldValue?

    override func setUp() {
        super.setUp()
        dataType = .text // for cases where the type doesn't matter
        options = Condition.Options(value: nil) // for cases where the options don't matter
    }

    override func tearDown() {
        super.tearDown()
        dataType = nil
        options = nil
        value = nil
    }

    // MARK: - does not equal

    func test_match_doesNotEqual_bothNil_doesNotMatch() {
        options = Condition.Options(value: nil)
        value = nil

        let isMatch = Query.doesNotEqual.match(value: value, dataType: dataType, options: options)

        XCTAssertFalse(isMatch)
    }

    func test_match_doesNotEqual_onlyOptionNil_matches() {
        dataType = .text
        options = Condition.Options(value: nil)
        let value: FieldValue? = .string("hello")

        let isMatch = Query.doesNotEqual.match(value: value, dataType: dataType, options: options)

        XCTAssertTrue(isMatch)
    }

    func test_match_doesNotEqual_onlyValueNil_matches() {
        dataType = .text
        options = Condition.Options(value: "hello")
        let value: FieldValue? = nil

        let isMatch = Query.doesNotEqual.match(value: value, dataType: dataType, options: options)

        XCTAssertTrue(isMatch)
    }

    func test_match_doesNotEqual_differentStrings_matches() {
        dataType = .text
        options = Condition.Options(value: "a")
        let value: FieldValue? = .string("b")

        let isMatch = Query.doesNotEqual.match(value: value, dataType: dataType, options: options)

        XCTAssertTrue(isMatch)
    }

    func test_match_doesNotEqual_sameString_doesNotMatch() {
        dataType = .text
        options = Condition.Options(value: "a")
        let value: FieldValue? = .string("a")

        let isMatch = Query.doesNotEqual.match(value: value, dataType: dataType, options: options)

        XCTAssertFalse(isMatch)
    }

    func test_match_doesNotEqual_differentCase_matches() {
        dataType = .text
        options = Condition.Options(value: "a")
        let value: FieldValue? = .string("A")

        let isMatch = Query.doesNotEqual.match(value: value, dataType: dataType, options: options)

        XCTAssertTrue(isMatch)
    }

    // MARK: - equals

    func test_match_equals_bothNil_matches() {
        options = Condition.Options(value: nil)
        value = nil

        let isMatch = Query.equals.match(value: value, dataType: dataType, options: options)

        XCTAssertTrue(isMatch)
    }

    func test_match_equals_onlyOptionNil_doesNotMatch() {
        dataType = .text
        options = Condition.Options(value: nil)
        let value: FieldValue? = .string("hello")

        let isMatch = Query.equals.match(value: value, dataType: dataType, options: options)

        XCTAssertFalse(isMatch)
    }

    func test_match_equals_onlyValueNil_doesNotMatch() {
        dataType = .text
        options = Condition.Options(value: "hello")
        let value: FieldValue? = nil

        let isMatch = Query.equals.match(value: value, dataType: dataType, options: options)

        XCTAssertFalse(isMatch)
    }

    func test_match_equals_differentStrings_doesNotMatch() {
        dataType = .text
        options = Condition.Options(value: "a")
        let value: FieldValue? = .string("b")

        let isMatch = Query.equals.match(value: value, dataType: dataType, options: options)

        XCTAssertFalse(isMatch)
    }

    func test_match_equals_sameString_matches() {
        dataType = .text
        options = Condition.Options(value: "a")
        let value: FieldValue? = .string("a")

        let isMatch = Query.equals.match(value: value, dataType: dataType, options: options)

        XCTAssertTrue(isMatch)
    }

    func test_match_equals_differentCase_doesNotMatch() {
        dataType = .text
        options = Condition.Options(value: "a")
        let value: FieldValue? = .string("A")

        let isMatch = Query.equals.match(value: value, dataType: dataType, options: options)

        XCTAssertFalse(isMatch)
    }
}
