import Foundation

struct DateTimeUtils {
    static let serverDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

//    does not work with JSONDecoder
//    static let serverISO8601DateTimeFormatter: ISO8601DateFormatter = {
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        return formatter
//    }()

    private static let humanDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d, YYYY h:mm a"
        return formatter
    }()

    static func add(days: Int, to dateTime: Date) -> Date? {
        Calendar.current.date(byAdding: .day, value: days, to: dateTime)
    }

    static func dateTime(fromServerString dateString: String?) -> Date? {
        guard let dateString = dateString else {
            return nil
        }

        return DateTimeUtils.serverDateTimeFormatter.date(from: dateString)
    }

    static func humanString(fromServerString dateString: String?) -> String? {
        let dateTime = dateTime(fromServerString: dateString)
        return humanString(from: dateTime)
    }

    static func humanString(from dateTime: Date?) -> String? {
        guard let dateTime = dateTime else {
            return nil
        }

        return DateTimeUtils.humanDateTimeFormatter.string(from: dateTime)
    }

    static func serverString(from date: Date?) -> String? {
        guard let date = date else {
            return nil
        }

        let result = DateTimeUtils.serverDateTimeFormatter.string(from: date)
        // split out for debug interception
        return result
    }

    static func isCurrentMonth(_ dateString: String?) -> Bool {
        isMonthOffset(dateString, by: 0)
    }

    static func isMonthOffset(_ dateString: String?, by numMonths: Int) -> Bool {
        guard let dateTime = dateTime(fromServerString: dateString),
              let offsetDateTime = Calendar.current.date(byAdding: .month, value: numMonths, to: Date()) else {
            return false
        }
        let dateTimeComponents = Calendar.current.dateComponents([.year, .month], from: dateTime)
        let offsetComponents = Calendar.current.dateComponents([.year, .month], from: offsetDateTime)

        return dateTimeComponents == offsetComponents
    }
}
