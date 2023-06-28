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
        let actions = [Action(command: .setValue, field: "A", value: Value.specificValue.rawValue)]
        let fieldValues: [String: FieldValue?] = ["A": .string("B")]
        let elements = [
            Element(id: "A", attributes: Element.Attributes(
                elementType: .field,
                dataType: .text,
                options: Element.Options(initialSpecificValue: .string("C"))
            ))
        ]
        let result = apply(actions: actions, to: fieldValues, elements: elements)
        XCTAssertEqual(result, ["A": .string("C")])
    }

    func test_applyActionsToElements_withMultipleActions_appliesTheActionsInOrder() {
        let actions = [
            Action(command: .setValue, field: "A", value: Value.specificValue.rawValue),
            Action(command: .setValue, field: "A", value: Value.empty.rawValue)
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
