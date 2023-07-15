@testable import Riverbed
import XCTest

final class UtilsTests: XCTestCase {
    let dictionary: [String: String?] = ["A": "B", "C": nil]

    // MARK: - apply(actions:to:elements:)

    func test_applyActionsToElements_withNoActions_returnsFieldValuesUnchanged() {
        let actions: [Action] = []
        let fieldValues: [String: FieldValue?] = ["A": .string("B"), "C": .dictionary(["D": "E"]), "F": nil]
        let elements = [Element]()
        let result = apply(actions: actions, to: fieldValues, elements: elements)
        XCTAssertEqual(result, fieldValues)
    }

    func test_applyActionsToElements_withOneActions_appliesTheActionToTheFieldValues() {
        let actions = [Action(command: .setValue,
                              field: "A",
                              value: Value.specificValue,
                              specificValue: .string("C"))]
        let fieldValues: [String: FieldValue?] = ["A": .string("B")]
        let elements = [
            Element(id: "A", attributes: Element.Attributes(
                elementType: .field,
                dataType: .text))
        ]
        let result = apply(actions: actions, to: fieldValues, elements: elements)
        XCTAssertEqual(result, ["A": .string("C")])
    }

    func test_applyActionsToElements_withMultipleActions_appliesTheActionsInOrder() {
        let actions = [
            Action(command: .setValue, field: "A", value: Value.specificValue),
            Action(command: .setValue, field: "A", value: Value.empty)
        ]
        let fieldValues: [String: FieldValue?] = ["A": .string("B")]
        let elements = [
            Element(id: "A", attributes: Element.Attributes(
                elementType: .field,
                dataType: .text,
                options: Element.Options(initialSpecificValue: .string("C"))
            ))
        ] // element has to exist; test the opposite
        let result = apply(actions: actions, to: fieldValues, elements: elements)
        XCTAssertEqual(result, ["A": nil])
    }

    // MARK: - domain(for:)

    func test_domainFor_invalidUrl_shouldReturnStringUnchanged() {
        let result = domain(for: "nonurl")
        XCTAssertEqual(result, "nonurl")
    }

    func test_domainFor_urlWithNoHostName_shouldReturnStringUnchanged() {
        let result = domain(for: "/path/to/file")
        XCTAssertEqual(result, "/path/to/file")
    }

    func test_domainFor_rootDomain_shouldReturnFullDomain() {
        let result = domain(for: "https://codingitwrong.com/books")
        XCTAssertEqual(result, "codingitwrong.com")
    }

    func test_domainFor_subdomain_shouldReturnSubdomain() {
        let result = domain(for: "https://api.riverbed.app/boards")
        XCTAssertEqual(result, "api.riverbed.app")
    }

    func test_domainFor_wwwSubdomain_shouldReturnDomainOnly() {
        let result = domain(for: "https://www.codingitwrong.com/books")
        XCTAssertEqual(result, "codingitwrong.com")
    }

    // MARK: - getInitialValues(forElements:)

    func test_getInitialValuesForElements_returnsAllConfiguredValues() {
        let elements = [
            Element(id: "button", attributes: Element.Attributes(
                elementType: .button)),
            Element(id: "no_initial_value", attributes: Element.Attributes(
                elementType: .field,
                initialValue: nil)),
            Element(id: "initial_empty", attributes: Element.Attributes(
                elementType: .field,
                dataType: .text,
                initialValue: .empty)),
            Element(id: "initial_specific", attributes: Element.Attributes(
                elementType: .field,
                dataType: .text,
                options: Element.Options(initialSpecificValue: .string("hi")),
                initialValue: .specificValue))
        ]

        let result = getInitialValues(forElements: elements)

        XCTAssertEqual(result, ["initial_empty": nil,
                                "initial_specific": .string("hi")])
    }

    // MARK: - isValidEmail()

    func test_isValidEmail_withEmptyString_returnsFalse() {
        XCTAssertFalse(isValidEmail(""))
    }

    func test_isValidEmail_withSimpleString_returnsFalse() {
        XCTAssertFalse(isValidEmail("example"))
    }

    func test_isValidEmail_withOnlyDomain_returnsFalse() {
        XCTAssertFalse(isValidEmail("example.com"))
    }

    func test_isValidEmail_withInvalidDomain_returnsFalse() {
        XCTAssertFalse(isValidEmail("example@example"))
    }

    func test_isValidEmail_withBasicEmail_returnsTrue() {
        XCTAssertTrue(isValidEmail("example@example.com"))
    }

    func test_isValidEmail_withTwoAts_returnsTrue() {
        XCTAssertFalse(isValidEmail("example@example@example.com"))
    }

    func test_isValidEmail_withSpecialCharacters_returnsTrue() {
        XCTAssertTrue(isValidEmail("example+more@example.com"))
    }

    func test_isValidEmail_withInvalidCharactersInTLD_returnsfalse() {
        XCTAssertFalse(isValidEmail("example+more@example.a11y"))
    }

    // MARK: - singularizeOptionality()

    func test_singularizeOptionality_withAValue_returnsTheValue() {
        let input: String?? = dictionary["A"]
        let expectedOutput: String? = "B"
        XCTAssertEqual(singularizeOptionality(input), expectedOutput)
    }

    func test_singularizeOptionality_withSingleOptional_returnsNil() {
        let input: String?? = dictionary["C"] // single optional
        let expectedOutput: String? = nil
        XCTAssertEqual(singularizeOptionality(input), expectedOutput)
    }

    func test_singularizeOptionality_withDoubleOptional_returnsNil() {
        let input: String?? = dictionary["D"] // double optional, like, no optional found
        let expectedOutput: String? = nil
        XCTAssertEqual(singularizeOptionality(input), expectedOutput)
    }

}
