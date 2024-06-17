@testable import Riverbed
import XCTest

final class DateUtilsTests: XCTestCase {
    let calendar = Calendar.current
    
    func assertDateEquals(year: Int,
                          month: Int,
                          day: Int,
                          hour: Int,
                          minute: Int,
                          second: Int,
                          _ date: Date?) {
        
        XCTAssertNotNil(date)
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!)
        
        XCTAssertEqual(year, dateComponents.year)
        XCTAssertEqual(month, dateComponents.month)
        XCTAssertEqual(day, dateComponents.day)
        XCTAssertEqual(hour, dateComponents.hour)
        XCTAssertEqual(minute, dateComponents.minute)
        XCTAssertEqual(second, dateComponents.second)
    }
    
    func test_dateFromServerString_withNil_returnsNil() {
        let result = DateUtils.date(fromServerString: nil)
        XCTAssertNil(result)
    }
    
    func test_dateFromServerString_withInvalidDate_returnsNil() {
        let result = DateUtils.date(fromServerString: "blah")
        XCTAssertNil(result)
    }
    
    func test_dateFromServerString_withValidDate_returnsDate() {
        let result = DateUtils.date(fromServerString: "2024-06-17")
        assertDateEquals(year: 2024, month: 6, day: 17, hour: 0, minute: 0, second: 0, result)
    }
}
