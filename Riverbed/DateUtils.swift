import Foundation

struct DateUtils {
    private static let serverDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    private static let humanDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d, YYYY"
        return formatter
    }()

    static func date(fromServerString dateString: String?) -> Date? {
        guard let dateString = dateString else {
            return nil
        }

        return DateUtils.serverDateFormatter.date(from: dateString)
    }

    static func humanString(fromServerString dateString: String?) -> String? {
        guard let date = date(fromServerString: dateString) else {
            return nil
        }

        return DateUtils.humanDateFormatter.string(from: date)
    }
}
