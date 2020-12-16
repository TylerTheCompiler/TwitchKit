//
//  DateFormatter+Extensions.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/10/20.
//

extension DateFormatter {
    internal static let zeroedOutTimeInternetDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T00:00:00Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
