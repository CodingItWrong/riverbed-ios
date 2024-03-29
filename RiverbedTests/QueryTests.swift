@testable import Riverbed
import XCTest

final class QueryTests: XCTestCase {
    let dummyOptions = Condition.Options(value: .string("DUMMY"))

    // MARK: - contains

    func test_contains_optionNil_matches() {
        // no constraint specified, so accept all
        let isMatch = Query.contains.match(value: .string("anything"),
                                           dataType: .text,
                                           options: Condition.Options(value: nil))
        XCTAssertTrue(isMatch)
    }

    func test_contains_optionAndValueNil_matches() {
        // no constraint specified, so accept even nothing
        let isMatch = Query.contains.match(value: nil,
                                           dataType: .text,
                                           options: Condition.Options(value: nil))
        XCTAssertTrue(isMatch)
    }

    func test_contains_valueNil_doesNotMatch() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: nil,
                                           dataType: .text,
                                           options: Condition.Options(value: .string("a")))
        XCTAssertFalse(isMatch)
    }

    func test_contains_equal_matches() {
        let isMatch = Query.contains.match(value: .string("abc"),
                                           dataType: .text,
                                           options: Condition.Options(value: .string("abc")))
        XCTAssertTrue(isMatch)
    }

    func test_contains_differentCase_matches() {
        let isMatch = Query.contains.match(value: .string("AbC"),
                                           dataType: .text,
                                           options: Condition.Options(value: .string("aBc")))
        XCTAssertTrue(isMatch)
    }

    func test_contains_substring_matches() {
        let isMatch = Query.contains.match(value: .string("abcd"),
                                           dataType: .text,
                                           options: Condition.Options(value: .string("bc")))
        XCTAssertTrue(isMatch)
    }

    func test_contains_differentStrings_doesNotMatch() {
        let isMatch = Query.contains.match(value: .string("ab"),
                                           dataType: .text,
                                           options: Condition.Options(value: .string("cd")))
        XCTAssertFalse(isMatch)
    }

    func test_contains_geolocation_doesNotMatch() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "1",
            GeolocationElementCell.ValueKey.longitude.rawValue: "2"]),
                                           dataType: .text,
                                           options: Condition.Options(value: .string("1")))
        XCTAssertFalse(isMatch)
    }

    func test_contains_portionOfNumber_matches() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: .string("1234"),
                                           dataType: .number,
                                           options: Condition.Options(value: .string("23")))
        XCTAssertTrue(isMatch)
    }

    func test_contains_differentNumber_doesNotMatch() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: .string("12"),
                                           dataType: .number,
                                           options: Condition.Options(value: .string("23")))
        XCTAssertFalse(isMatch)
    }

    func test_contains_portionOfDate_matches() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: .string("1984-01-24"),
                                           dataType: .date,
                                           options: Condition.Options(value: .string("1-2")))
        XCTAssertTrue(isMatch)
    }

    func test_contains_differentDate_doesNotMatch() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: .string("1984-01-24"),
                                           dataType: .date,
                                           options: Condition.Options(value: .string("1981")))
        XCTAssertFalse(isMatch)
    }

    func test_contains_portionOfDateTime_matches() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: .string("1984-01-24T09:41:00.000Z"),
                                           dataType: .dateTime,
                                           options: Condition.Options(value: .string("24T09")))
        XCTAssertTrue(isMatch)
    }

    func test_contains_differentDateTime_doesNotMatch() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: .string("1984-01-24T09:41:00.000Z"),
                                           dataType: .dateTime,
                                           options: Condition.Options(value: .string("1981")))
        XCTAssertFalse(isMatch)
    }

    func test_contains_sameChoice_matches() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: .string("fake_uuid"),
                                           dataType: .choice,
                                           options: Condition.Options(value: .string("fake_uuid")))
        XCTAssertTrue(isMatch)
    }

    func test_contains_choiceSubstring_doesNotMatch() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: .string("fake_uuid"),
                                           dataType: .choice,
                                           options: Condition.Options(value: .string("ke_uu")))
        XCTAssertFalse(isMatch)
    }

    func test_contains_differentChoice_doesNotMatch() {
        // there is a constraint and no value, so do not accept
        let isMatch = Query.contains.match(value: .string("fake_uuid"),
                                           dataType: .choice,
                                           options: Condition.Options(value: .string("different_uuid")))
        XCTAssertFalse(isMatch)
    }

    // MARK: - does not contain

    func test_doesNotContain_optionNil_doesNotMatch() {
        // no constraint specified, so reject none
        let isMatch = Query.doesNotContain.match(value: .string("anything"),
                                           dataType: .text,
                                           options: Condition.Options(value: nil))
        XCTAssertFalse(isMatch)
    }

    func test_doesNotContain_optionAndValueNil_doesNotMatch() {
        // no constraint specified, so do not reject even nothing
        let isMatch = Query.doesNotContain.match(value: nil,
                                           dataType: .text,
                                           options: Condition.Options(value: nil))
        XCTAssertFalse(isMatch)
    }

    func test_doesNotContain_valueNil_matches() {
        // there is a constraint and no value, so it does not contain it
        let isMatch = Query.doesNotContain.match(value: nil,
                                           dataType: .text,
                                           options: Condition.Options(value: .string("a")))
        XCTAssertTrue(isMatch)
    }

    func test_doesNotContain_equal_doesNotMatch() {
        let isMatch = Query.doesNotContain.match(value: .string("abc"),
                                           dataType: .text,
                                           options: Condition.Options(value: .string("abc")))
        XCTAssertFalse(isMatch)
    }

    func test_doesNotContain_differentCase_doesNotMatch() {
        let isMatch = Query.doesNotContain.match(value: .string("AbC"),
                                           dataType: .text,
                                           options: Condition.Options(value: .string("aBc")))
        XCTAssertFalse(isMatch)
    }

    func test_doesNotContain_substring_doesNotMatch() {
        let isMatch = Query.doesNotContain.match(value: .string("abcd"),
                                           dataType: .text,
                                           options: Condition.Options(value: .string("bc")))
        XCTAssertFalse(isMatch)
    }

    func test_contains_differentStrings_matches() {
        let isMatch = Query.doesNotContain.match(value: .string("ab"),
                                           dataType: .text,
                                           options: Condition.Options(value: .string("cd")))
        XCTAssertTrue(isMatch)
    }

    // MARK: - does not equal

    func test_match_doesNotEqual_bothNil_doesNotMatch() {
        let isMatch = Query.doesNotEqual.match(value: nil,
                                               dataType: .text,
                                               options: Condition.Options(value: nil))

        XCTAssertFalse(isMatch)
    }

    func test_match_doesNotEqual_onlyOptionNil_matches() {
        let isMatch = Query.doesNotEqual.match(value: .string("hello"),
                                               dataType: .text,
                                               options: Condition.Options(value: nil))

        XCTAssertTrue(isMatch)
    }

    func test_match_doesNotEqual_onlyValueNil_matches() {
        let isMatch = Query.doesNotEqual.match(value: nil,
                                               dataType: .text,
                                               options: Condition.Options(value: .string("hello")))

        XCTAssertTrue(isMatch)
    }

    func test_match_doesNotEqual_differentStrings_matches() {
        let isMatch = Query.doesNotEqual.match(value: .string("a"),
                                               dataType: .text,
                                               options: Condition.Options(value: .string("b")))

        XCTAssertTrue(isMatch)
    }

    func test_match_doesNotEqual_differentCase_matches() {
        let isMatch = Query.doesNotEqual.match(value: .string("a"),
                                               dataType: .text,
                                               options: Condition.Options(value: .string("A")))

        XCTAssertTrue(isMatch)
    }

    // MARK: - equals

    func test_match_equals_bothNil_matches() {
        let isMatch = Query.equals.match(value: nil,
                                         dataType: .text,
                                         options: Condition.Options(value: nil))

        XCTAssertTrue(isMatch)
    }

    func test_match_equals_onlyOptionNil_doesNotMatch() {
        let isMatch = Query.equals.match(value: .string("hello"),
                                         dataType: .text,
                                         options: Condition.Options(value: nil))

        XCTAssertFalse(isMatch)
    }

    func test_match_equals_onlyValueNil_doesNotMatch() {
        let isMatch = Query.equals.match(value: nil,
                                         dataType: .text,
                                         options: Condition.Options(value: .string("hello")))

        XCTAssertFalse(isMatch)
    }

    func test_match_equals_differentStrings_doesNotMatch() {
        let isMatch = Query.equals.match(value: .string("a"),
                                         dataType: .text,
                                         options: Condition.Options(value: .string("b")))

        XCTAssertFalse(isMatch)
    }

    func test_match_equals_sameString_matches() {
        let isMatch = Query.equals.match(value: .string("a"),
                                         dataType: .text,
                                         options: Condition.Options(value: .string("a")))

        XCTAssertTrue(isMatch)
    }

    func test_match_equals_differentCase_doesNotMatch() {
        let isMatch = Query.equals.match(value: .string("a"),
                                         dataType: .text,
                                         options: Condition.Options(value: .string("A")))

        XCTAssertFalse(isMatch)
    }

    func test_match_equals_differentDictionary_doesNotMatch() {
        let isMatch = Query.equals.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "1.234",
            GeolocationElementCell.ValueKey.longitude.rawValue: "2.345"]),
                                         dataType: .geolocation,
                                         options: Condition.Options(value:
                                                .dictionary([GeolocationElementCell.ValueKey.latitude.rawValue: "1.234",
                                                    GeolocationElementCell.ValueKey.longitude.rawValue: "3.456"])))

        XCTAssertFalse(isMatch)
    }

    func test_match_equals_sameDictionary_matches() {
        let isMatch = Query.equals.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "1.234",
            GeolocationElementCell.ValueKey.longitude.rawValue: "2.345"]),
                                         dataType: .geolocation,
                                         options: Condition.Options(value:
                                                .dictionary([GeolocationElementCell.ValueKey.latitude.rawValue: "1.234",
                                                    GeolocationElementCell.ValueKey.longitude.rawValue: "2.345"])))

        XCTAssertTrue(isMatch)
    }

    // MARK: - is current month

    func test_match_isCurrentMonth_choice_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: .string("fake_uuid"),
                                                 dataType: .choice,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_geolocation_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "0",
            GeolocationElementCell.ValueKey.longitude.rawValue: "0"]),
                                                 dataType: .geolocation,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_number_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: .string("1"),
                                                 dataType: .number,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_text_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: .string("a"),
                                                 dataType: .text,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_date_nil_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: nil,
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_date_invalidDate_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: .string("not a date"),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_date_dateTime_doesNotMatch() {
        // not a date in the current month, because it's a datetime
        let isMatch = Query.isCurrentMonth.match(value: .string("2999-01-01T00:00:00.000Z"),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_date_longPast_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: .string("1984-01-24"),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_date_previousMonth_doesNotMatch() {
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        guard let previousMonthString = DateUtils.serverString(from: previousMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isCurrentMonth.match(value: .string(previousMonthString),
                                                 dataType: .date,
                                                 options: dummyOptions)

        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_date_currentMonth_matches() {
        guard let nowString = DateUtils.serverString(from: Date()) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isCurrentMonth.match(value: .string(nowString),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isCurrentMonth_date_nextMonth_doesNotMatch() {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        guard let nextMonthString = DateUtils.serverString(from: nextMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isCurrentMonth.match(value: .string(nextMonthString),
                                                 dataType: .date,
                                                 options: dummyOptions)

        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_date_farFuture_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: .string("2999-01-01"),
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_dateTime_nil_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: nil,
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_dateTime_invalidDate_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: .string("not a date"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_dateTime_date_doesNotMatch() {
        // not a datetime in the current month, because it's a date
        let isMatch = Query.isCurrentMonth.match(value: .string("2999-01-01"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_dateTime_longPast_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: .string("1984-01-24T00:00:00.000Z"),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_dateTime_previousMonth_doesNotMatch() {
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        guard let previousMonthString = DateTimeUtils.serverString(from: previousMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isCurrentMonth.match(value: .string(previousMonthString),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)

        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_dateTime_currentMonth_matches() {
        guard let nowString = DateTimeUtils.serverString(from: Date()) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isCurrentMonth.match(value: .string(nowString),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isCurrentMonth_dateTime_nextMonth_doesNotMatch() {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        guard let nextMonthString = DateTimeUtils.serverString(from: nextMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isCurrentMonth.match(value: .string(nextMonthString),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)

        XCTAssertFalse(isMatch)
    }

    func test_match_isCurrentMonth_dateTime_farFuture_doesNotMatch() {
        let isMatch = Query.isCurrentMonth.match(value: .string("2999-01-01T00:00:00.000Z"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    // MARK: - is empty

    func test_isEmpty_nil_matches() {
        let isMatch = Query.isEmpty.match(value: nil,
                                          dataType: .text,
                                          options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_isEmpty_emptyString_matches() {
        let isMatch = Query.isEmpty.match(value: .string(""),
                                          dataType: .text,
                                          options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_isEmpty_nonEmptyString_doesNotMatch() {
        let isMatch = Query.isEmpty.match(value: .string("a"),
                                          dataType: .text,
                                          options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    // MARK: - is empty or equals

    func test_match_isEmptyOrEquals_bothNil_matches() {
        let isMatch = Query.isEmptyOrEquals.match(value: nil,
                                                  dataType: .text,
                                                  options: Condition.Options(value: nil))
        XCTAssertTrue(isMatch)
    }

    func test_match_isEmptyOrEquals_onlyOptionNil_doesNotMatch() {
        let isMatch = Query.isEmptyOrEquals.match(value: .string("hello"),
                                                  dataType: .text,
                                                  options: Condition.Options(value: nil))
        XCTAssertFalse(isMatch)
    }

    func test_match_isEmptyOrEquals_onlyValueNil_matches() {
        let isMatch = Query.isEmptyOrEquals.match(value: nil,
                                                  dataType: .text,
                                                  options: Condition.Options(value: .string("hello")))
        XCTAssertTrue(isMatch)
    }

    func test_match_isEmptyOrEquals_onlyValueEmptyString_matches() {
        let isMatch = Query.isEmptyOrEquals.match(value: .string(""),
                                                  dataType: .text,
                                                  options: Condition.Options(value: .string("hello")))
        XCTAssertTrue(isMatch)
    }

    func test_match_isEmptyOrEquals_differentStrings_doesNotMatch() {
        let isMatch = Query.isEmptyOrEquals.match(value: .string("a"),
                                                  dataType: .text,
                                                  options: Condition.Options(value: .string("b")))
        XCTAssertFalse(isMatch)
    }

    func test_match_isEmptyOrEquals_sameString_matches() {
        let isMatch = Query.isEmptyOrEquals.match(value: .string("a"),
                                                  dataType: .text,
                                                  options: Condition.Options(value: .string("a")))
        XCTAssertTrue(isMatch)
    }

    func test_match_isEmptyOrEquals_differentCase_doesNotMatch() {
        let isMatch = Query.isEmptyOrEquals.match(value: .string("a"),
                                                  dataType: .text,
                                                  options: Condition.Options(value: .string("A")))
        XCTAssertFalse(isMatch)
    }

    func test_match_isEmptyOrEquals_differentDictionary_doesNotMatch() {
        let isMatch = Query.isEmptyOrEquals.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "1.234",
            GeolocationElementCell.ValueKey.longitude.rawValue: "2.345"]),
                                         dataType: .geolocation,
                                         options: Condition.Options(value:
                                                .dictionary([GeolocationElementCell.ValueKey.latitude.rawValue: "1.234",
                                                    GeolocationElementCell.ValueKey.longitude.rawValue: "3.456"])))

        XCTAssertFalse(isMatch)
    }

    func test_match_isEmptyOrEquals_sameDictionary_matches() {
        let isMatch = Query.isEmptyOrEquals.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "1.234",
            GeolocationElementCell.ValueKey.longitude.rawValue: "2.345"]),
                                         dataType: .geolocation,
                                         options: Condition.Options(value:
                                                .dictionary([GeolocationElementCell.ValueKey.latitude.rawValue: "1.234",
                                                    GeolocationElementCell.ValueKey.longitude.rawValue: "2.345"])))

        XCTAssertTrue(isMatch)
    }

    // MARK: - is future

    func test_match_isFuture_choice_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: .string("fake_uuid"),
                                                 dataType: .choice,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_geolocation_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "0",
            GeolocationElementCell.ValueKey.longitude.rawValue: "0"]),
                                                 dataType: .geolocation,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_number_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: .string("1"),
                                                 dataType: .number,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_text_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: .string("a"),
                                                 dataType: .text,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_date_nil_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: nil,
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_date_invalidDate_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: .string("not a date"),
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_date_dateTime_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: .string("2999-01-01T00:00:00.000Z"),
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_date_past_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: .string("1984-01-24"),
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_date_future_matches() {
        let isMatch = Query.isFuture.match(value: .string("2999-01-01"),
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isFuture_dateTime_nil_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: nil,
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_dateTime_invalidDate_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: .string("not a date"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_dateTime_date_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: .string("2999-01-01"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_dateTime_past_doesNotMatch() {
        let isMatch = Query.isFuture.match(value: .string("1984-01-24T00:00:00.000Z"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isFuture_dateTime_future_matches() {
        let isMatch = Query.isFuture.match(value: .string("2999-01-01T00:00:00.000Z"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    // MARK: - is not current month

    func test_match_isNotCurrentMonth_choice_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: .string("fake_uuid"),
                                                 dataType: .choice,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_geolocation_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "0",
            GeolocationElementCell.ValueKey.longitude.rawValue: "0"]),
                                                 dataType: .geolocation,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_number_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: .string("1"),
                                                 dataType: .number,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_text_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: .string("a"),
                                                 dataType: .text,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_date_nil_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: nil,
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_date_invalidDate_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: .string("not a date"),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_date_dateTime_matches() {
        // not a date in the current month, because it's a datetime
        let isMatch = Query.isNotCurrentMonth.match(value: .string("2999-01-01T00:00:00.000Z"),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_date_longPast_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: .string("1984-01-24"),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_date_previousMonth_matches() {
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        guard let previousMonthString = DateUtils.serverString(from: previousMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isNotCurrentMonth.match(value: .string(previousMonthString),
                                                 dataType: .date,
                                                 options: dummyOptions)

        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_date_currentMonth_doesNotMatch() {
        guard let nowString = DateUtils.serverString(from: Date()) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isNotCurrentMonth.match(value: .string(nowString),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isNotCurrentMonth_date_nextMonth_matches() {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        guard let nextMonthString = DateUtils.serverString(from: nextMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isNotCurrentMonth.match(value: .string(nextMonthString),
                                                 dataType: .date,
                                                 options: dummyOptions)

        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_date_farFuture_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: .string("2999-01-01"),
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_dateTime_nil_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: nil,
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_dateTime_invalidDate_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: .string("not a date"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_dateTime_date_matches() {
        // not a datetime in the current month, because it's a date
        let isMatch = Query.isNotCurrentMonth.match(value: .string("2999-01-01"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_dateTime_longPast_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: .string("1984-01-24T00:00:00.000Z"),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_dateTime_previousMonth_matches() {
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        guard let previousMonthString = DateTimeUtils.serverString(from: previousMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isNotCurrentMonth.match(value: .string(previousMonthString),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)

        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_dateTime_currentMonth_doesNotMatch() {
        guard let nowString = DateTimeUtils.serverString(from: Date()) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isNotCurrentMonth.match(value: .string(nowString),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isNotCurrentMonth_dateTime_nextMonth_matches() {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        guard let nextMonthString = DateTimeUtils.serverString(from: nextMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isNotCurrentMonth.match(value: .string(nextMonthString),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)

        XCTAssertTrue(isMatch)
    }

    func test_match_isNotCurrentMonth_dateTime_farFuture_matches() {
        let isMatch = Query.isNotCurrentMonth.match(value: .string("2999-01-01T00:00:00.000Z"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    // MARK: - is not empty

    func test_isNotEmpty_nil_doesNotMatch() {
        let isMatch = Query.isNotEmpty.match(value: nil,
                                          dataType: .text,
                                          options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_isNotEmpty_emptyString_doesNotMatch() {
        let isMatch = Query.isNotEmpty.match(value: .string(""),
                                          dataType: .text,
                                          options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_isNotEmpty_nonEmptyString_matches() {
        let isMatch = Query.isNotEmpty.match(value: .string("a"),
                                          dataType: .text,
                                          options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    // MARK: - is not future

    func test_match_isNotFuture_choice_matches() {
        let isMatch = Query.isNotFuture.match(value: .string("fake_uuid"),
                                                 dataType: .choice,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_geolocation_matches() {
        let isMatch = Query.isNotFuture.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "0",
            GeolocationElementCell.ValueKey.longitude.rawValue: "0"]),
                                                 dataType: .geolocation,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_number_matches() {
        let isMatch = Query.isNotFuture.match(value: .string("1"),
                                                 dataType: .number,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_text_matches() {
        let isMatch = Query.isNotFuture.match(value: .string("a"),
                                                 dataType: .text,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_date_nil_matches() {
        // not a future date because it's not a date
        let isMatch = Query.isNotFuture.match(value: nil,
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_date_invalidDate_matches() {
        // not a future date because it's not a date
        let isMatch = Query.isNotFuture.match(value: .string("not a date"),
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_date_dateTime_doesNotMatch() {
        // not a future date because it's a datetime not a date
        let isMatch = Query.isNotFuture.match(value: .string("2999-01-01T00:00:00.000Z"),
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_date_past_matches() {
        let isMatch = Query.isNotFuture.match(value: .string("1984-01-24"),
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_date_future_doesNotMatch() {
        let isMatch = Query.isNotFuture.match(value: .string("2999-01-01"),
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isNotFuture_dateTime_nil_matches() {
        // not a future datetime because it's not a datetime
        let isMatch = Query.isNotFuture.match(value: nil,
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_dateTime_invalidDate_matches() {
        // not a future datetime because it's not a datetime
        let isMatch = Query.isNotFuture.match(value: .string("not a date"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_dateTime_date_matches() {
        // not a future datetime because it's a date not a datetime
        let isMatch = Query.isNotFuture.match(value: .string("2999-01-01"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_dateTime_past_matches() {
        let isMatch = Query.isNotFuture.match(value: .string("1984-01-24T00:00:00.000Z"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotFuture_dateTime_future_matches() {
        let isMatch = Query.isNotFuture.match(value: .string("2999-01-01T00:00:00.000Z"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    // MARK: - is not past

    func test_match_isNotPast_choice_matches() {
        let isMatch = Query.isNotPast.match(value: .string("fake_uuid"),
                                                 dataType: .choice,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotPast_geolocation_matches() {
        let isMatch = Query.isNotPast.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "0",
            GeolocationElementCell.ValueKey.longitude.rawValue: "0"]),
                                                 dataType: .geolocation,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotPast_number_matches() {
        let isMatch = Query.isNotPast.match(value: .string("1"),
                                                 dataType: .number,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotPast_text_matches() {
        let isMatch = Query.isNotPast.match(value: .string("a"),
                                                 dataType: .text,
                                                 options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotPast_date_nil_matches() {
        // not past because not a date
        let isMatch = Query.isNotPast.match(value: nil,
                                         dataType: .date,
                                         options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotPast_date_invalidDate_matches() {
        // not past because not a date
        let isMatch = Query.isNotPast.match(value: .string("not a date"),
                                         dataType: .date,
                                         options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotPast_date_dateTime_matches() {
        // not a past date because it's a datetime not a date
        let isMatch = Query.isNotPast.match(value: .string("2999-01-01T00:00:00.000Z"),
                                         dataType: .date,
                                         options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotPast_date_past_doesNotMatch() {
        let isMatch = Query.isNotPast.match(value: .string("1984-01-24"),
                                         dataType: .date,
                                         options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isNotPast_date_future_matches() {
        let isMatch = Query.isNotPast.match(value: .string("2999-01-01"),
                                         dataType: .date,
                                         options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotPast_dateTime_nil_matches() {
        // not past because not a date
        let isMatch = Query.isNotPast.match(value: nil,
                                         dataType: .dateTime,
                                         options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotPast_dateTime_invalidDate_matches() {
        // not past because not a date
        let isMatch = Query.isNotPast.match(value: .string("not a date"),
                                         dataType: .dateTime,
                                         options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotPast_dateTime_date_matches() {
        // not a past datetime because it's a date not a datetime
        let isMatch = Query.isNotPast.match(value: .string("2999-01-01"),
                                         dataType: .dateTime,
                                         options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isNotPast_dateTime_past_doesNotMatch() {
        let isMatch = Query.isNotPast.match(value: .string("1984-01-24T00:00:00.000Z"),
                                         dataType: .dateTime,
                                         options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isNotPast_dateTime_future_matches() {
        let isMatch = Query.isNotPast.match(value: .string("2999-01-01T00:00:00.000Z"),
                                         dataType: .dateTime,
                                         options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    // MARK: - is past

    func test_match_isPast_choice_doesNotMatch() {
        let isMatch = Query.isPast.match(value: .string("fake_uuid"),
                                                 dataType: .choice,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPast_geolocation_doesNotMatch() {
        let isMatch = Query.isPast.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "0",
            GeolocationElementCell.ValueKey.longitude.rawValue: "0"]),
                                                 dataType: .geolocation,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPast_number_doesNotMatch() {
        let isMatch = Query.isPast.match(value: .string("1"),
                                                 dataType: .number,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPast_text_doesNotMatch() {
        let isMatch = Query.isPast.match(value: .string("a"),
                                                 dataType: .text,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPast_date_nil_doesNotMatch() {
        let isMatch = Query.isPast.match(value: nil,
                                         dataType: .date,
                                         options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPast_date_invalidDate_doesNotMatch() {
        let isMatch = Query.isPast.match(value: .string("not a date"),
                                         dataType: .date,
                                         options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPast_date_dateTime_doesNotMatch() {
        // not a past date because it's a datetime not a date
        let isMatch = Query.isPast.match(value: .string("2999-01-01T00:00:00.000Z"),
                                         dataType: .date,
                                         options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPast_date_past_matches() {
        let isMatch = Query.isPast.match(value: .string("1984-01-24"),
                                         dataType: .date,
                                         options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isPast_date_future_doesNotMatch() {
        let isMatch = Query.isPast.match(value: .string("2999-01-01"),
                                         dataType: .date,
                                         options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPast_dateTime_nil_doesNotMatch() {
        let isMatch = Query.isPast.match(value: nil,
                                         dataType: .dateTime,
                                         options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPast_dateTime_invalidDate_doesNotMatch() {
        let isMatch = Query.isPast.match(value: .string("not a date"),
                                         dataType: .dateTime,
                                         options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPast_dateTime_date_doesNotMatch() {
        // not a past datetime because it's a date not a datetime
        let isMatch = Query.isPast.match(value: .string("2999-01-01"),
                                         dataType: .dateTime,
                                         options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPast_dateTime_past_matches() {
        let isMatch = Query.isPast.match(value: .string("1984-01-24T00:00:00.000Z"),
                                         dataType: .dateTime,
                                         options: dummyOptions)
        XCTAssertTrue(isMatch)
    }

    func test_match_isPast_dateTime_future_doesNotMatch() {
        let isMatch = Query.isPast.match(value: .string("2999-01-01T00:00:00.000Z"),
                                         dataType: .dateTime,
                                         options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    // MARK: - is previous month

    func test_match_isPreviousMonth_choice_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: .string("fake_uuid"),
                                                 dataType: .choice,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_geolocation_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: .dictionary([
            GeolocationElementCell.ValueKey.latitude.rawValue: "0",
            GeolocationElementCell.ValueKey.longitude.rawValue: "0"]),
                                                 dataType: .geolocation,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_number_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: .string("1"),
                                                 dataType: .number,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_text_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: .string("a"),
                                                 dataType: .text,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_date_nil_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: nil,
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_date_invalidDate_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: .string("not a date"),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_date_dateTime_doesNotMatch() {
        // not a date in the current month, because it's a datetime
        let isMatch = Query.isPreviousMonth.match(value: .string("2999-01-01T00:00:00.000Z"),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_date_longPast_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: .string("1984-01-24"),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_date_previousMonth_matches() {
        // NOTE: possible this test may run across boundary conditions around the start of a month
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        guard let previousMonthString = DateUtils.serverString(from: previousMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isPreviousMonth.match(value: .string(previousMonthString),
                                                 dataType: .date,
                                                 options: dummyOptions)

        XCTAssertTrue(isMatch)
    }

    func test_match_isPreviousMonth_date_currentMonth_doesNotMatch() {
        guard let nowString = DateUtils.serverString(from: Date()) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isPreviousMonth.match(value: .string(nowString),
                                                 dataType: .date,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_date_nextMonth_doesNotMatch() {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        guard let nextMonthString = DateUtils.serverString(from: nextMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isPreviousMonth.match(value: .string(nextMonthString),
                                                 dataType: .date,
                                                 options: dummyOptions)

        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_date_farFuture_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: .string("2999-01-01"),
                                           dataType: .date,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_dateTime_nil_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: nil,
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_dateTime_invalidDate_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: .string("not a date"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_dateTime_date_doesNotMatch() {
        // not a datetime in the current month, because it's a date
        let isMatch = Query.isPreviousMonth.match(value: .string("2999-01-01"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_dateTime_longPast_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: .string("1984-01-24T00:00:00.000Z"),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_dateTime_previousMonth_matches() {
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        guard let previousMonthString = DateTimeUtils.serverString(from: previousMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isPreviousMonth.match(value: .string(previousMonthString),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)

        XCTAssertTrue(isMatch)
    }

    func test_match_isPreviousMonth_dateTime_currentMonth_doesNotMatch() {
        guard let nowString = DateTimeUtils.serverString(from: Date()) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isPreviousMonth.match(value: .string(nowString),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_dateTime_nextMonth_doesNotMatch() {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        guard let nextMonthString = DateTimeUtils.serverString(from: nextMonth) else {
            XCTFail("precondition")
            return
        }

        let isMatch = Query.isPreviousMonth.match(value: .string(nextMonthString),
                                                 dataType: .dateTime,
                                                 options: dummyOptions)

        XCTAssertFalse(isMatch)
    }

    func test_match_isPreviousMonth_dateTime_farFuture_doesNotMatch() {
        let isMatch = Query.isPreviousMonth.match(value: .string("2999-01-01T00:00:00.000Z"),
                                           dataType: .dateTime,
                                           options: dummyOptions)
        XCTAssertFalse(isMatch)
    }

}
