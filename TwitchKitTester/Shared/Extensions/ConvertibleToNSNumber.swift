//
//  ConvertibleToNSNumber.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 11/19/20.
//

import Foundation

protocol ConvertibleToNSNumber {
    var nsNumberValue: NSNumber { get }
}

extension Int: ConvertibleToNSNumber { var nsNumberValue: NSNumber { .init(value: self) } }
extension Int8: ConvertibleToNSNumber { var nsNumberValue: NSNumber { .init(value: self) } }
extension Int16: ConvertibleToNSNumber { var nsNumberValue: NSNumber { .init(value: self) } }
extension Int32: ConvertibleToNSNumber { var nsNumberValue: NSNumber { .init(value: self) } }
extension Int64: ConvertibleToNSNumber { var nsNumberValue: NSNumber { .init(value: self) } }
extension UInt: ConvertibleToNSNumber { var nsNumberValue: NSNumber { .init(value: self) } }
extension UInt8: ConvertibleToNSNumber { var nsNumberValue: NSNumber { .init(value: self) } }
extension UInt16: ConvertibleToNSNumber { var nsNumberValue: NSNumber { .init(value: self) } }
extension UInt32: ConvertibleToNSNumber { var nsNumberValue: NSNumber { .init(value: self) } }
extension UInt64: ConvertibleToNSNumber { var nsNumberValue: NSNumber { .init(value: self) } }
