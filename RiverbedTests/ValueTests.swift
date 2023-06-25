@testable import Riverbed
import XCTest

final class ValueTests: XCTestCase {
    func test_callFieldDataTypeOptions_withEmpty_returnsNone() {
        let result = Value.empty.call(fieldDataType: .text, options: nil)
        XCTAssertEqual(result, .none)
    }

    func test_callFieldDataTypeOptions_withSpecificValue_returnsInitialSpecificValue() {
        let initialValue = FieldValue.string("HI")
        let options = Element.Options(initialSpecificValue: initialValue)

        let result = Value.specificValue.call(fieldDataType: .text, options: options)

        XCTAssertEqual(result, initialValue)
    }

    func test_callFieldDataTypeOptions_withNowForDateField() {
        let result = Value.now.call(fieldDataType: .date, options: nil)

        // TODO: how to mock the current date?
    }
}
