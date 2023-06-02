@testable import Riverbed
import XCTest

final class UtilsTests: XCTestCase {
    let dictionary: [String: String?] = ["A": "B", "C": nil]

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
}
