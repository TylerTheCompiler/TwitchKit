//
//  AccessTokenTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/11/20.
//

import XCTest
@testable import TwitchKit

class AccessTokenTests: XCTestCase {
    
    // MARK: - User Access Token
    
    func test_userAccessToken_stringInitializer() throws {
        let accessTokenString = "MockAccessToken"
        let accessToken = UserAccessToken(stringValue: accessTokenString)
        XCTAssertEqual(accessToken.stringValue, accessTokenString, "Incorrect string value")
    }
    
    func test_userAccessToken_decodesFromStringValue() throws {
        let accessTokenString = "MockAccessToken"
        let data = try JSONEncoder().encode([accessTokenString])
        let accessTokens = try JSONDecoder().decode([UserAccessToken].self, from: data)
        XCTAssertEqual(accessTokens.first?.stringValue, accessTokenString, "Incorrect string value")
    }
    
    func test_userAccessToken_encodesToStringValue() throws {
        let accessTokenString = "MockAccessToken"
        let accessToken = UserAccessToken(stringValue: accessTokenString)
        let data = try JSONEncoder().encode(accessToken)
        let string = String(data: data, encoding: .utf8)
        XCTAssertEqual(string, "\"\(accessTokenString)\"", "Incorrect string value")
    }
    
    func test_validatedUserAccessToken_stringInitializer() throws {
        let accessTokenString = "MockAccessToken"
        let userId = "MockUserId"
        let login = "MockUserLogin"
        let clientId = "MockClientId"
        let scopes = Set([Scope.userReadEmail, .bitsRead, .channelEditCommercial])
        let date = Date()
        
        let validation = UserAccessToken.Validation(userId: userId,
                                                    login: login,
                                                    clientId: clientId,
                                                    scopes: scopes,
                                                    date: date)
        let accessToken = ValidatedUserAccessToken(stringValue: accessTokenString, validation: validation)
        XCTAssertEqual(accessToken.stringValue, accessTokenString, "Incorrect string value")
        XCTAssertEqual(accessToken.validation, validation, "Incorrect validation value")
    }
    
    func test_validatedUserAccessToken_decodesFromJSONObject_withDate() throws {
        let accessTokenString = "MockAccessToken"
        let clientId = "MockClientId"
        let userId = "MockUserId"
        let login = "MockUserLogin"
        let scopes = Set([Scope.userEdit, .bitsRead, .channelManageRedemptions])
        let date = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate)
        
        let data = Data("""
        {
            "string_value": "\(accessTokenString)",
            "validation": {
                "client_id": "\(clientId)",
                "user_id": "\(userId)",
                "login": "\(login)",
                "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))],
                "date": \(date.timeIntervalSinceReferenceDate)
            }
        }
        """.utf8)
        
        let expectedValidation = UserAccessToken.Validation(userId: userId,
                                                            login: login,
                                                            clientId: clientId,
                                                            scopes: scopes,
                                                            date: date)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let accessToken = try decoder.decode(ValidatedUserAccessToken.self, from: data)
        XCTAssertEqual(accessToken.stringValue, accessTokenString, "Incorrect string value")
        XCTAssertEqual(accessToken.validation, expectedValidation, "Incorrect validation value")
    }
    
    func test_validatedUserAccessToken_decodesFromJSONObject_withoutDate() throws {
        let accessTokenString = "MockAccessToken"
        let clientId = "MockClientId"
        let userId = "MockUserId"
        let login = "MockUserLogin"
        let scopes = Set([Scope.userEdit, .bitsRead, .channelManageRedemptions])
        
        let data = Data("""
        {
            "string_value": "\(accessTokenString)",
            "validation": {
                "client_id": "\(clientId)",
                "user_id": "\(userId)",
                "login": "\(login)",
                "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]
            }
        }
        """.utf8)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let accessToken = try decoder.decode(ValidatedUserAccessToken.self, from: data)
        XCTAssertEqual(accessToken.stringValue, accessTokenString, "Incorrect string value")
        XCTAssertEqual(accessToken.validation.clientId, clientId, "Incorrect client ID")
        XCTAssertEqual(accessToken.validation.userId, userId, "Incorrect user ID")
        XCTAssertEqual(accessToken.validation.login, login, "Incorrect login")
        XCTAssertEqual(accessToken.validation.scopes, scopes, "Incorrect scopes")
        XCTAssertEqual(accessToken.validation.date.timeIntervalSinceReferenceDate,
                       Date().timeIntervalSinceReferenceDate,
                       accuracy: 0.001,
                       "Incorrect date")
    }
    
    func test_validatedUserAccessToken_encodesToJSONObject() throws {
        let accessTokenString = "MockAccessToken"
        let userId = "MockUserId"
        let login = "MockUserLogin"
        let clientId = "MockClientId"
        let scopes = Set([Scope.userReadEmail, .bitsRead, .channelEditCommercial])
        let date = Date()
        
        let validation = UserAccessToken.Validation(userId: userId,
                                                    login: login,
                                                    clientId: clientId,
                                                    scopes: scopes,
                                                    date: date)
        let accessToken = ValidatedUserAccessToken(stringValue: accessTokenString, validation: validation)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(accessToken)
        
        guard let jsonDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            XCTFail("Expected to encode ValidatedUserAccessToken to a dictionary")
            return
        }
        
        XCTAssertEqual(jsonDict["string_value"] as? String, accessTokenString, "Incorrect string value")
        
        guard let validationDict = jsonDict["validation"] as? [String: Any] else {
            XCTFail("Expected to encode validation to a dictionary")
            return
        }
        
        XCTAssertEqual(validationDict["user_id"] as? String, userId, "Incorrect string value")
        XCTAssertEqual(validationDict["login"] as? String, login, "Incorrect login")
        XCTAssertEqual(validationDict["client_id"] as? String, clientId, "Incorrect client ID")
        
        XCTAssertEqual(Set(validationDict["scopes"] as? [String] ?? []), Set(scopes.map(\.rawValue)),
                       "Incorrect scopes")
        
        XCTAssertEqual(Date(timeIntervalSinceReferenceDate: validationDict["date"] as? TimeInterval ?? 0), date,
                       "Incorrect date")
    }
    
    func test_validatedUserAccessToken_unvalidatedReturnsCorrectValue() throws {
        let accessTokenString = "MockAccessToken"
        let userId = "MockUserId"
        let login = "MockUserLogin"
        let clientId = "MockClientId"
        let scopes = Set([Scope.userReadEmail, .bitsRead, .channelEditCommercial])
        let date = Date()
        
        let validation = UserAccessToken.Validation(userId: userId,
                                                    login: login,
                                                    clientId: clientId,
                                                    scopes: scopes,
                                                    date: date)
        let validatedAccessToken = ValidatedUserAccessToken(stringValue: accessTokenString, validation: validation)
        let expectedAccessToken = UserAccessToken(stringValue: accessTokenString)
        
        XCTAssertEqual(validatedAccessToken.unvalidated, expectedAccessToken,
                       "Incorrect access token value")
    }
    
    // MARK: - App Access Token
    
    func test_appAccessToken_stringInitializer() throws {
        let accessTokenString = "MockAccessToken"
        let accessToken = AppAccessToken(stringValue: accessTokenString)
        XCTAssertEqual(accessToken.stringValue, accessTokenString, "Incorrect string value")
    }
    
    func test_appAccessToken_decodesFromStringValue() throws {
        let accessTokenString = "MockAccessToken"
        let data = try JSONEncoder().encode([accessTokenString])
        let accessTokens = try JSONDecoder().decode([AppAccessToken].self, from: data)
        XCTAssertEqual(accessTokens.first?.stringValue, accessTokenString, "Incorrect string value")
    }
    
    func test_appAccessToken_encodesToStringValue() throws {
        let accessTokenString = "MockAccessToken"
        let accessToken = AppAccessToken(stringValue: accessTokenString)
        let data = try JSONEncoder().encode(accessToken)
        let string = String(data: data, encoding: .utf8)
        XCTAssertEqual(string, "\"\(accessTokenString)\"", "Incorrect string value")
    }
    
    func test_validatedAppAccessToken_stringInitializer() throws {
        let accessTokenString = "MockAccessToken"
        let clientId = "MockClientId"
        let scopes = Set([Scope.userReadEmail, .bitsRead, .channelEditCommercial])
        let date = Date()
        
        let validation = AppAccessToken.Validation(clientId: clientId, scopes: scopes, date: date)
        let accessToken = ValidatedAppAccessToken(stringValue: accessTokenString, validation: validation)
        XCTAssertEqual(accessToken.stringValue, accessTokenString, "Incorrect string value")
        XCTAssertEqual(accessToken.validation, validation, "Incorrect validation value")
    }
    
    func test_validatedAppAccessToken_decodesFromJSONObject_withDate() throws {
        let accessTokenString = "MockAccessToken"
        let clientId = "MockClientId"
        let scopes = Set([Scope.userEdit, .bitsRead, .channelManageRedemptions])
        let date = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate)
        
        let data = Data("""
        {
            "string_value": "\(accessTokenString)",
            "validation": {
                "client_id": "\(clientId)",
                "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))],
                "date": \(date.timeIntervalSinceReferenceDate)
            }
        }
        """.utf8)
        
        let expectedValidation = AppAccessToken.Validation(clientId: clientId, scopes: scopes, date: date)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let accessToken = try decoder.decode(ValidatedAppAccessToken.self, from: data)
        XCTAssertEqual(accessToken.stringValue, accessTokenString, "Incorrect string value")
        XCTAssertEqual(accessToken.validation, expectedValidation, "Incorrect validation value")
    }
    
    func test_validatedAppAccessToken_decodesFromJSONObject_withoutDate() throws {
        let accessTokenString = "MockAccessToken"
        let clientId = "MockClientId"
        let scopes = Set([Scope.userEdit, .bitsRead, .channelManageRedemptions])
        
        let data = Data("""
        {
            "string_value": "\(accessTokenString)",
            "validation": {
                "client_id": "\(clientId)",
                "scopes": [\(scopes.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]
            }
        }
        """.utf8)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let accessToken = try decoder.decode(ValidatedAppAccessToken.self, from: data)
        XCTAssertEqual(accessToken.stringValue, accessTokenString, "Incorrect string value")
        XCTAssertEqual(accessToken.validation.clientId, clientId, "Incorrect client ID")
        XCTAssertEqual(accessToken.validation.scopes, scopes, "Incorrect scopes")
        XCTAssertEqual(accessToken.validation.date.timeIntervalSinceReferenceDate,
                       Date().timeIntervalSinceReferenceDate,
                       accuracy: 0.001,
                       "Incorrect date")
    }
    
    func test_validatedAppAccessToken_encodesToJSONObject() throws {
        let accessTokenString = "MockAccessToken"
        let clientId = "MockClientId"
        let scopes = Set([Scope.userReadEmail, .bitsRead, .channelEditCommercial])
        let date = Date()
        
        let validation = AppAccessToken.Validation(clientId: clientId, scopes: scopes, date: date)
        let accessToken = ValidatedAppAccessToken(stringValue: accessTokenString, validation: validation)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(accessToken)
        
        guard let jsonDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            XCTFail("Expected to encode ValidatedUserAccessToken to a dictionary")
            return
        }
        
        XCTAssertEqual(jsonDict["string_value"] as? String, accessTokenString, "Incorrect string value")
        
        guard let validationDict = jsonDict["validation"] as? [String: Any] else {
            XCTFail("Expected to encode validation to a dictionary")
            return
        }
        
        XCTAssertEqual(validationDict["client_id"] as? String, clientId, "Incorrect client ID")
        
        XCTAssertEqual(Set(validationDict["scopes"] as? [String] ?? []), Set(scopes.map(\.rawValue)),
                       "Incorrect scopes")
        
        XCTAssertEqual(Date(timeIntervalSinceReferenceDate: validationDict["date"] as? TimeInterval ?? 0), date,
                       "Incorrect date")
    }
    
    func test_validatedAppAccessToken_unvalidatedReturnsCorrectValue() throws {
        let accessTokenString = "MockAccessToken"
        let clientId = "MockClientId"
        let scopes = Set([Scope.userReadEmail, .bitsRead, .channelEditCommercial])
        let date = Date()
        
        let validation = AppAccessToken.Validation(clientId: clientId, scopes: scopes, date: date)
        let validatedAccessToken = ValidatedAppAccessToken(stringValue: accessTokenString, validation: validation)
        let expectedAccessToken = AppAccessToken(stringValue: accessTokenString)
        
        XCTAssertEqual(validatedAccessToken.unvalidated, expectedAccessToken,
                       "Incorrect access token value")
    }
}
