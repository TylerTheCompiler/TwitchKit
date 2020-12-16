//
//  DateFormatterExtensionTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/10/20.
//

import XCTest
@testable import TwitchKit

class DateFormatterExtensionTests: XCTestCase {
    func test_zeroedOutDateFormatter_zeroesOutTime() throws {
        let zeroingDateFormatter = DateFormatter.zeroedOutTimeInternetDateFormatter
        
        let calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone(secondsFromGMT: 0)!
        var fullDateComponents = DateComponents()
        fullDateComponents.calendar = calendar
        fullDateComponents.timeZone = timeZone
        fullDateComponents.era = 1
        fullDateComponents.year = 2020
        fullDateComponents.month = 12
        fullDateComponents.day = 10
        fullDateComponents.hour = 10
        fullDateComponents.minute = 30
        fullDateComponents.second = 45
        fullDateComponents.nanosecond = 1234
        
        var dateComponentsWithZeroedTime = fullDateComponents
        dateComponentsWithZeroedTime.hour = 0
        dateComponentsWithZeroedTime.minute = 0
        dateComponentsWithZeroedTime.second = 0
        dateComponentsWithZeroedTime.nanosecond = 0
        
        let dateString = zeroingDateFormatter.string(from: fullDateComponents.date!)
        guard let date = zeroingDateFormatter.date(from: dateString) else {
            XCTFail("Expected date formatter to format string into date")
            return
        }
        
        var newDateComponents = calendar.dateComponents(in: timeZone, from: date)
        newDateComponents.weekday = nil
        newDateComponents.weekdayOrdinal = nil
        newDateComponents.quarter = nil
        newDateComponents.weekOfMonth = nil
        newDateComponents.weekOfYear = nil
        newDateComponents.yearForWeekOfYear = nil
        newDateComponents.isLeapMonth = nil
        
        print(newDateComponents)
        
        print(dateComponentsWithZeroedTime)
        
        XCTAssertEqual(newDateComponents, dateComponentsWithZeroedTime,
                       "Expected date formatter to zero out hours, minutes, seconds, and milliseconds from date")
    }
}
