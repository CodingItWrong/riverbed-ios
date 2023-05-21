import Foundation

struct DateTimeUtils {
    private static let serverDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    private static let humanDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d, YYYY hh:mm:ss a"
        return formatter
    }()

    static func dateTime(fromServerString dateString: String?) -> Date? {
        guard let dateString = dateString else {
            return nil
        }

        return DateTimeUtils.serverDateTimeFormatter.date(from: dateString)
    }

    static func humanString(fromServerString dateString: String?) -> String? {
        guard let dateTime = dateTime(fromServerString: dateString) else {
            return nil
        }

        return DateTimeUtils.humanDateTimeFormatter.string(from: dateTime)
    }
}
