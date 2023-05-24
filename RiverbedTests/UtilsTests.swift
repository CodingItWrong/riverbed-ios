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

//    func shouldNotCompileDueToDoubleOptinoal() {
//        if let input = dictionary["D"] {
//            input.index(after: 0) // input is still optional
//        }
//    }
}
