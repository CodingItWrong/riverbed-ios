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
    
    func test_addDaysTo_with2Days_returnsDateWithTwoDaysAdded() {
        let startDate = Date.with(year: 2024, month: 6, day: 17)!
        let result = DateUtils.add(days: 2, to: startDate)
        assertDateEquals(year: 2024, month: 6, day: 19, hour: 0, minute: 0, second: 0, result)
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
    
    func test_humanStringFromServerString_withNil_returnsNil() {
        let result = DateUtils.humanString(fromServerString: nil)
        XCTAssertNil(result)
    }
    
    func test_humanStringFromServerString_withInvalidDate_returnsNil() {
        let result = DateUtils.humanString(fromServerString: "blah")
        XCTAssertNil(result)
    }
    
    func test_humanStringFromServerString_withValidDate_returnsFormattedDate() {
        let result = DateUtils.humanString(fromServerString: "2024-06-17")
        XCTAssertEqual("Mon Jun 17, 2024", result)
    }
    
    func test_serverStringFrom_withNil_returnsNil() {
        let result = DateUtils.serverString(from: nil)
        XCTAssertNil(result)
    }
    
    func test_serverStringFrom_withDate_returnsFormattedDate() {
        let date = Date.with(year: 2024, month: 6, day: 17)!
        let result = DateUtils.serverString(from: date)
        XCTAssertEqual("2024-06-17", result)
    }
}

extension Date {
    static func with(year: Int,
                     month: Int,
                     day: Int,
                     hour: Int = 0,
                     minute: Int = 0,
                     second: Int = 0) -> Date?
    {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        return Calendar.current.date(from: dateComponents)
    }
}
