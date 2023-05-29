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

    static func add(days: Int, to date: Date) -> Date? {
        Calendar.current.date(byAdding: .day, value: days, to: date)
    }

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

    static func serverString(from date: Date?) -> String? {
        guard let date = date else {
            return nil
        }

        return DateUtils.serverDateFormatter.string(from: date)
    }

    static func isCurrentMonth(_ dateString: String?) -> Bool {
        isMonthOffset(dateString, by: 0)
    }

    static func isMonthOffset(_ dateString: String?, by numMonths: Int) -> Bool {
        guard let date = date(fromServerString: dateString),
              let offsetDate = Calendar.current.date(byAdding: .month, value: numMonths, to: Date()) else {
            return false
        }
        let dateComponents = Calendar.current.dateComponents([.year, .month], from: date)
        let offsetComponents = Calendar.current.dateComponents([.year, .month], from: offsetDate)

        return dateComponents == offsetComponents
    }
}
