@testable import Riverbed
import XCTest

final class ValueTests: XCTestCase {
    func test_callFieldDataTypeOptions_withEmptyForText_returnsNone() {
        let result = Value.empty.call(fieldDataType: .text, specificValue: nil)
        XCTAssertEqual(result, .none)
    }

    func test_callFieldDataTypeOptions_withEmptyForGeolocation_returnsNone() {
        let result = Value.empty.call(fieldDataType: .geolocation, specificValue: nil)
        XCTAssertEqual(result, .none)
    }

    func test_callFieldDataTypeOptions_withSpecificValue_returnsInitialSpecificValue() {
        let specificValue = FieldValue.string("HI")

        let result = Value.specificValue.call(fieldDataType: .text, specificValue: specificValue)

        XCTAssertEqual(result, specificValue)
    }

    func test_callFieldDataTypeOptions_withNowForDateField() {
        Value.now.call(fieldDataType: .date, specificValue: nil)

        // TODO: how to mock the current date?
    }
}
