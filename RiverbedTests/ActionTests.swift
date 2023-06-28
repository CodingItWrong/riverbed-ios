@testable import Riverbed
import XCTest

final class ActionTests: XCTestCase {
    func test_call_withEmptyCommand_returnsFieldValuesUnchanged() {
        let fieldValues: [String: FieldValue?] = ["A": .string("B")]
        let action = Action(command: nil, field: "A")
        let result = action.call(elements: [], fieldValues: fieldValues)
        XCTAssertEqual(result, fieldValues)
    }

    func test_call_configuredToSetValueToEmpty_returnsFieldValuesWithValueSetToNil() {
        let elements = [
            Element(id: "A", attributes: Element.Attributes(
                elementType: .field,
                dataType: .text,
                options: Element.Options()))
        ]
        let fieldValues: [String: FieldValue?] = ["A": .string("B")]
        let action = Action(command: .setValue, field: "A", value: .empty)
        let result = action.call(elements: elements, fieldValues: fieldValues)
        XCTAssertEqual(result, ["A": nil])
    }

    func test_call_configuredToAdd2DaysToFutureDate_returnsFieldValuesWithDate2DaysLater() {
        let elements = [
            Element(id: "A", attributes: Element.Attributes(
                elementType: .field,
                dataType: .date,
                options: Element.Options()))
        ]
        let fieldValues: [String: FieldValue?] = ["A": .string("2999-01-01")]
        let action = Action(command: .addDays, field: "A", specificValue: .string("2"))
        let result = action.call(elements: elements, fieldValues: fieldValues)
        XCTAssertEqual(result, ["A": .string("2999-01-03")])
    }

    func test_call_configuredToAddNegative1DaysToFutureDatetime_returnsFieldValuesWithDatetime1DayEarlier() {
        let elements = [
            Element(id: "A", attributes: Element.Attributes(
                elementType: .field,
                dataType: .dateTime,
                options: Element.Options()))
        ]
        let fieldValues: [String: FieldValue?] = ["A": .string("2999-01-10T09:00:00.000Z")]
        let action = Action(command: .addDays, field: "A", specificValue: .string("-1"))
        let result = action.call(elements: elements, fieldValues: fieldValues)
        XCTAssertEqual(result, ["A": .string("2999-01-09T09:00:00.000Z")])
    }
}
