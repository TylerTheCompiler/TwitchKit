//
//  IdTokenTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/11/20.
//

import XCTest
@testable import TwitchKit

class IdTokenTests: XCTestCase {
    func test_givenCorrectIdTokenString_initializerSucceeds() {
        let nonce = UUID().uuidString
        let idTokenString = idToken(nonce: nonce)
        
        do {
            let idToken = try IdToken(stringValue: idTokenString, expectedNonce: nonce)
            
            XCTAssertEqual(idToken.rawValue, idTokenString, "Incorrect raw value")
            XCTAssertEqual(idToken.payload["nonce"] as? String, nonce, "Incorrect nonce")
        } catch {
            XCTFail("Expected IdToken to parse correctly, got: \(error)")
            return
        }
    }
    
    func test_givenInvalidFormat_initializerFails() {
        do {
            _ = try IdToken(stringValue: "SomeInvalidToken", expectedNonce: nil)
        } catch IdToken.ParseError.invalidFormat {
            return
        } catch {
            XCTFail("Expected \(IdToken.ParseError.invalidFormat), got: \(error)")
            return
        }
        
        XCTFail("Expected to throw error")
    }
    
    func test_givenThreeStringsSeparatedByPeriod_butWithStillInvalidFormat_initializerFails() {
        do {
            _ = try IdToken(stringValue: "Some .Invalid.Token", expectedNonce: nil)
        } catch IdToken.ParseError.invalidFormat {
            return
        } catch {
            XCTFail("Expected \(IdToken.ParseError.invalidFormat), got: \(error)")
            return
        }
        
        XCTFail("Expected to throw error")
    }
    
    func test_givenInvalidDefaultClaims_initializerFails() {
        let nonce = UUID().uuidString
        let idTokenString = idToken(nonce: nonce, messUpDefaultClaims: true)
        
        do {
            _ = try IdToken(stringValue: idTokenString, expectedNonce: nonce)
        } catch IdToken.ParseError.missingOrInvalidDefaultClaims {
            return
        } catch {
            XCTFail("Expected \(IdToken.ParseError.missingOrInvalidDefaultClaims), got: \(error)")
            return
        }
        
        XCTFail("Expected to throw error")
    }
    
    func test_givenValidIdTokenString_butMismatchedNonce_initializerFails() {
        let nonce = UUID().uuidString
        let idTokenString = idToken(nonce: nonce)
        
        do {
            _ = try IdToken(stringValue: idTokenString, expectedNonce: "SomeInvalidNonce")
        } catch IdToken.ParseError.mismatchedNonce {
            return
        } catch {
            XCTFail("Expected \(IdToken.ParseError.mismatchedNonce), got: \(error)")
            return
        }
        
        XCTFail("Expected to throw error")
    }
    
    func test_idToken_decodesFromStringValue() throws {
        let nonce = UUID().uuidString
        let idTokenString = idToken(nonce: nonce)
        let data = try JSONEncoder().encode([idTokenString])
        let decoder = JSONDecoder()
        decoder.userInfo[.expectedNonce] = nonce
        let idTokens = try decoder.decode([IdToken].self, from: data)
        XCTAssertEqual(idTokens.first?.rawValue, idTokenString, "Incorrect raw value")
    }
    
    func test_idToken_failsToDecodeFromStringValue_ifNoNonceIsSetOnTheDecoder() throws {
        let nonce = UUID().uuidString
        let idTokenString = idToken(nonce: nonce)
        let data = try JSONEncoder().encode([idTokenString])
        do {
            _ = try JSONDecoder().decode([IdToken].self, from: data)
            XCTFail("Expected error to be thrown")
        } catch IdToken.ParseError.mismatchedNonce {
            return
        } catch {
            XCTFail("Expected \(IdToken.ParseError.mismatchedNonce), got: \(error)")
        }
    }
    
    func test_idToken_initializesWithRawValue_and_encodesToStringValue() throws {
        let nonce = UUID().uuidString
        let idTokenString = idToken(nonce: nonce)
        let idToken = IdToken(rawValue: idTokenString)
        XCTAssertEqual(idToken?.rawValue, idTokenString)
        
        let data = try JSONEncoder().encode(idToken)
        let string = try JSONDecoder().decode(String.self, from: data)
        XCTAssertEqual(string, idTokenString, "Incorrect string value")
    }
    
    private func idToken(nonce: String?, messUpDefaultClaims: Bool = false) -> String {
        let headerDict: [String: Any] = [
            "alg": "RS256",
            "typ": "JWT"
        ]
        
        var payloadDict: [String: Any] = [
            "iss": "MockIssuer",
            "sub": "MockSubject",
            "aud": "MockAudience",
            "exp": 1234,
            "iat": 2345,
            "email": "Kappa@Kappa.kappa",
            "email_verified": true,
            "picture": "https://d3aqoihi2n8ty8.cloudfront.net/actions/kappa/dark/animated/1000/4.gif",
            "preferred_username": "Kappa",
            "updated_at": ISO8601DateFormatter.internetDateWithFractionalSecondsFormatter.string(from: Date())
        ]
        
        payloadDict["nonce"] = nonce
        
        if messUpDefaultClaims {
            payloadDict["aud"] = nil
        }
        
        let header = try! JSONSerialization.data(withJSONObject: headerDict, options: .sortedKeys)
        let payload = try! JSONSerialization.data(withJSONObject: payloadDict, options: .sortedKeys)
        let signature = "MockSignature"
        
        return [
            header.base64URLEncodedString,
            payload.base64URLEncodedString,
            signature
        ].joined(separator: ".")
    }
}
