//
//  PropertyWrapperTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/12/20.
//

import XCTest
@testable import TwitchKit

class PropertyWrapperTests: XCTestCase {
    
    // MARK: - Pagination
    
    func test_pagination_decodesFromDictionaryJSON() throws {
        let cursor = "SomeCursorValue"
        let data = Data("{\"cursor\": \"\(cursor)\"}".utf8)
        
        let pagination = try JSONDecoder().decode(Pagination.self, from: data)
        
        XCTAssertEqual(pagination.wrappedValue?.rawValue, cursor)
    }
    
    func test_pagination_decodesFromSingleValueJSON() throws {
        let cursor = "SomeCursorValue"
        let data = Data("[\"\(cursor)\"]".utf8)
        
        let pagination = try JSONDecoder().decode([Pagination].self, from: data).first
        
        XCTAssertEqual(pagination?.wrappedValue?.rawValue, cursor)
    }
    
    // MARK: - Dates
    
    enum MockDateConvertingStrategy: DateConvertingStrategy {
        static let anyDateString = "AnyDate"
        static func date(from string: String) -> Date? {
            string == anyDateString ? Date() : nil
        }
        
        static func string(from date: Date) -> String { anyDateString }
    }
    
    func test_givenDateStrategyThatCanConvertStringToDate_codableDate_decodesFromJSON() {
        let data = Data("[\"\(MockDateConvertingStrategy.anyDateString)\"]".utf8)
        
        do {
            _ = try JSONDecoder().decode([CodableDate<MockDateConvertingStrategy>].self, from: data)
        } catch {
            XCTFail("Expected not to get error, got: \(error)")
        }
    }
    
    func test_givenDateStrategyThatCannotConvertStringToDate_codableDate_throwsError() {
        let data = Data("[\"SomeStringThatCannotBeConvertedToDate\"]".utf8)
        
        do {
            _ = try JSONDecoder().decode([CodableDate<MockDateConvertingStrategy>].self, from: data)
            XCTFail("Expected to throw decoding error")
        } catch is DecodingError {
        } catch {
            XCTFail("Expected to catch \(DecodingError.self), got: \(error)")
        }
    }
    
    func test_codableDate_encodesToJSON() throws {
        let codableDate = CodableDate<MockDateConvertingStrategy>(wrappedValue: Date())
        
        let data = try JSONEncoder().encode(codableDate)
        XCTAssertEqual(String(data: data, encoding: .utf8), "\"AnyDate\"")
    }
    
    func test_optionalCodableDate_decodesFromJSON() {
        let data = Data("[\"\(MockDateConvertingStrategy.anyDateString)\"]".utf8)
        
        do {
            _ = try JSONDecoder().decode([OptionalCodableDate<MockDateConvertingStrategy>].self, from: data)
        } catch {
            XCTFail("Expected not to get error, got: \(error)")
        }
    }
    
    func test_optionalCodableDate_encodesToJSON() throws {
        let optionalCodableDate = OptionalCodableDate<MockDateConvertingStrategy>(wrappedValue: Date())
        
        let data = try JSONEncoder().encode(optionalCodableDate)
        XCTAssertEqual(String(data: data, encoding: .utf8), "\"AnyDate\"")
    }
    
    func test_givenNilWrappedValue_optionalCodableDate_encodesNilToJSON() throws {
        let optionalCodableDate = OptionalCodableDate<MockDateConvertingStrategy>(wrappedValue: nil)
        
        let data = try JSONEncoder().encode(optionalCodableDate)
        XCTAssertEqual(String(data: data, encoding: .utf8), "null")
    }
    
    func test_givenDateStrategyThatCanConvertStringToDate_codableDateInterval_decodesFromJSON() {
        enum MockDateConvertingStrategy: DateConvertingStrategy {
            static let startedAt = Date()
            static let endedAt = startedAt + 3600
            
            static func date(from string: String) -> Date? {
                string == "StartedAtDate" ? startedAt : endedAt
            }
            
            static func string(from date: Date) -> String {
                date == startedAt ? "StartedAtDate" : "EndedAtDate"
            }
        }
        
        let data = Data("""
        {
            "startedAt": "StartedAtDate",
            "endedAt": "EndedAtDate"
        }
        """.utf8)
        
        do {
            _ = try JSONDecoder().decode(CodableDateInterval<MockDateConvertingStrategy>.self, from: data)
        } catch {
            XCTFail("Expected not to get error, got: \(error)")
        }
    }
    
    func test_givenDateStrategyThatCanConvertStringToDate_butDateRangeIsInvalid_codableDateInterval_throwsError() {
        enum MockDateConvertingStrategy: DateConvertingStrategy {
            static let startedAt = Date()
            static let endedAt = startedAt - 3600
            
            static func date(from string: String) -> Date? {
                string == "StartedAtDate" ? startedAt : endedAt
            }
            
            static func string(from date: Date) -> String {
                date == startedAt ? "StartedAtDate" : "EndedAtDate"
            }
        }
        
        let data = Data("""
        {
            "startedAt": "StartedAtDate",
            "endedAt": "EndedAtDate"
        }
        """.utf8)
        
        do {
            _ = try JSONDecoder().decode(CodableDateInterval<MockDateConvertingStrategy>.self, from: data)
            XCTFail("Expected to throw decoding error")
        } catch is DecodingError {
        } catch {
            XCTFail("Expected to get \(DecodingError.self), got: \(error)")
        }
    }
    
    func test_codableDateInterval_encodesToJSON() throws {
        enum MockDateConvertingStrategy: DateConvertingStrategy {
            static var isFirstConversion = true
            
            static func date(from string: String) -> Date? {
                Date()
            }
            
            static func string(from date: Date) -> String {
                defer { isFirstConversion = false }
                return isFirstConversion ? "StartedAtDate" : "EndedAtDate"
            }
        }
        
        let codableDateInterval = CodableDateInterval<MockDateConvertingStrategy>(wrappedValue: .init(start: Date(), duration: 3600))
        
        let expectedString = """
        {"endedAt":"EndedAtDate","startedAt":"StartedAtDate"}
        """
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try JSONEncoder().encode(codableDateInterval)
        
        XCTAssertEqual(String(data: data, encoding: .utf8), expectedString)
    }
    
    func test_optionalCodableDateInterval_decodesFromJSON() {
        enum MockDateConvertingStrategy: DateConvertingStrategy {
            static let startedAt = Date()
            static let endedAt = startedAt + 3600
            
            static func date(from string: String) -> Date? {
                string == "StartedAtDate" ? startedAt : endedAt
            }
            
            static func string(from date: Date) -> String {
                date == startedAt ? "StartedAtDate" : "EndedAtDate"
            }
        }
        
        let data = Data("""
        {
            "startedAt": "StartedAtDate",
            "endedAt": "EndedAtDate"
        }
        """.utf8)
        
        do {
            _ = try JSONDecoder().decode(OptionalCodableDateInterval<MockDateConvertingStrategy>.self, from: data)
        } catch {
            XCTFail("Expected not to get error, got: \(error)")
        }
    }
    
    func test_optionalCodableDateInterval_encodesToJSON() throws {
        enum MockDateConvertingStrategy: DateConvertingStrategy {
            static var isFirstConversion = true
            
            static func date(from string: String) -> Date? {
                Date()
            }
            
            static func string(from date: Date) -> String {
                defer { isFirstConversion = false }
                return isFirstConversion ? "StartedAtDate" : "EndedAtDate"
            }
        }
        
        let codableDateInterval = OptionalCodableDateInterval<MockDateConvertingStrategy>(wrappedValue: .init(start: Date(), duration: 3600))
        
        let expectedString = """
        {"endedAt":"EndedAtDate","startedAt":"StartedAtDate"}
        """
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try JSONEncoder().encode(codableDateInterval)
        
        XCTAssertEqual(String(data: data, encoding: .utf8), expectedString)
    }
    
    func test_givenDateStrategyThatCanConvertStringToDate_butDateRangeIsInvalid_optionalCodableDateInterval_decodesFromJSON() {
        enum MockDateConvertingStrategy: DateConvertingStrategy {
            static let startedAt = Date()
            static let endedAt = startedAt - 3600
            
            static func date(from string: String) -> Date? {
                string == "StartedAtDate" ? startedAt : endedAt
            }
            
            static func string(from date: Date) -> String {
                date == startedAt ? "StartedAtDate" : "EndedAtDate"
            }
        }
        
        let data = Data("""
        {
            "startedAt": "StartedAtDate",
            "endedAt": "EndedAtDate"
        }
        """.utf8)
        
        do {
            _ = try JSONDecoder().decode(OptionalCodableDateInterval<MockDateConvertingStrategy>.self, from: data)
        } catch {
            XCTFail("Expected to not throw error, got: \(error)")
        }
    }
    
    func test_givenNilWrappedValue_optionalCodableDateInterval_encodesNilToJSON() throws {
        let optionalDateInterval = OptionalCodableDateInterval<MockDateConvertingStrategy>(wrappedValue: nil)
        
        let expectedString = """
        {"endedAt":null,"startedAt":null}
        """
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(optionalDateInterval)
        XCTAssertEqual(String(data: data, encoding: .utf8), expectedString)
    }
    
    // MARK: - Date Converting Strategies
    
    func test_internetDateConvertingStrategy_convertsStringToDate() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        
        let date = Date()
        let string = formatter.string(from: date)
        
        XCTAssertEqual(Double(Int(InternetDateConvertingStrategy.date(from: string)?.timeIntervalSince1970 ?? 0.0)),
                       Double(Int(date.timeIntervalSince1970)),
                       accuracy: 0.00001)
    }
    
    func test_internetDateConvertingStrategy_convertsDateToString() {
        let expectedDateString = "2020-12-15T01:19:10Z"
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        let date = formatter.date(from: expectedDateString)!
        
        XCTAssertEqual(InternetDateConvertingStrategy.string(from: date), expectedDateString)
    }
    
    func test_internetDateWithFractionalSecondsConvertingStrategy_convertsStringToDate() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let date = Date()
        let string = formatter.string(from: date)
        
        XCTAssertEqual(InternetDateWithFractionalSecondsConvertingStrategy.date(from: string)?.timeIntervalSince1970 ?? 0.0,
                       date.timeIntervalSince1970,
                       accuracy: 0.005)
    }
    
    func test_internetDateWithFractionalSecondsConvertingStrategy_convertsDateToString() {
        let expectedDateString = "2020-12-15T01:19:10.123Z"
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: expectedDateString)!
        
        XCTAssertEqual(InternetDateWithFractionalSecondsConvertingStrategy.string(from: date), expectedDateString)
    }
    
    func test_internetDateWithOptionalFractionalSecondsConvertingStrategy_convertsStringToDate() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        
        let date = Date()
        let string = formatter.string(from: date)
        
        XCTAssertEqual(Double(Int(InternetDateWithOptionalFractionalSecondsConvertingStrategy.date(from: string)?.timeIntervalSince1970 ?? 0.0)),
                       Double(Int(date.timeIntervalSince1970)),
                       accuracy: 0.00001)
    }
    
    func test_internetDateWithOptionalFractionalSecondsConvertingStrategy_convertsDateToString() {
        let expectedDateString = "2020-12-15T01:19:10.000Z"
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        let date = formatter.date(from: "2020-12-15T01:19:10Z")!
        
        XCTAssertEqual(InternetDateWithOptionalFractionalSecondsConvertingStrategy.string(from: date), expectedDateString)
    }
}
