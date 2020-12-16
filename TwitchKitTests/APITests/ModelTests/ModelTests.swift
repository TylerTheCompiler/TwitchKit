//
//  ModelTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/15/20.
//

import XCTest
@testable import TwitchKit

class ModelTests: XCTestCase {
    
    // MARK: - ActiveExtension
    
    func test_givenActiveIsTrue_andXAndYCoordinatesExist_activeExtension_decodesFromJSON() throws {
        let isActive = true
        let identifier = "SomeIdentifier"
        let version = "SomeVersion"
        let name = "SomeName"
        let xCoord = 100
        let yCoord = 200
        
        let data = Data("""
        {
            "active": \(isActive),
            "id": "\(identifier)",
            "version": "\(version)",
            "name": "\(name)",
            "x": \(xCoord),
            "y": \(yCoord)
        }
        """.utf8)
        
        let activeExtension = try JSONDecoder().decode(ActiveExtension.self, from: data)
        
        XCTAssertEqual(activeExtension.isActive, isActive)
        XCTAssertEqual(activeExtension.information?.id, identifier)
        XCTAssertEqual(activeExtension.information?.version, version)
        XCTAssertEqual(activeExtension.information?.name, name)
        XCTAssertEqual(activeExtension.information?.coordinates?.x, xCoord)
        XCTAssertEqual(activeExtension.information?.coordinates?.y, yCoord)
    }
    
    func test_givenActiveIsTrue_andXAndYCoordinatesDoNotExist_activeExtension_decodesFromJSON() throws {
        let isActive = true
        let identifier = "SomeIdentifier"
        let version = "SomeVersion"
        let name = "SomeName"
        
        let data = Data("""
        {
            "active": \(isActive),
            "id": "\(identifier)",
            "version": "\(version)",
            "name": "\(name)"
        }
        """.utf8)
        
        let activeExtension = try JSONDecoder().decode(ActiveExtension.self, from: data)
        
        XCTAssertEqual(activeExtension.isActive, isActive)
        XCTAssertEqual(activeExtension.information?.id, identifier)
        XCTAssertEqual(activeExtension.information?.version, version)
        XCTAssertEqual(activeExtension.information?.name, name)
        XCTAssertNil(activeExtension.information?.coordinates)
    }
    
    func test_givenActiveIsFalse_activeExtension_decodesFromJSON_andInformationIsNil() throws {
        let isActive = false
        
        let data = Data("""
        {
            "active": \(isActive)
        }
        """.utf8)
        
        let activeExtension = try JSONDecoder().decode(ActiveExtension.self, from: data)
        
        XCTAssertEqual(activeExtension.isActive, isActive)
        XCTAssertNil(activeExtension.information)
    }
    
    func test_activeExtension_information_equality() {
        let info1 = ActiveExtension.Information(id: "Id1",
                                                version: "Verion1",
                                                name: "Name1",
                                                coordinates: (100, 200))
        let info2 = ActiveExtension.Information(id: "Id1",
                                                version: "Verion1",
                                                name: "Name1",
                                                coordinates: (100, 200))
        XCTAssertEqual(info1, info2)
    }
    
    func test_activeExtension_information_inequalityDueToUnequalIdVersionOrName() {
        let info1 = ActiveExtension.Information(id: "Id1",
                                                version: "Verion1",
                                                name: "Name1",
                                                coordinates: (100, 200))
        let info2 = ActiveExtension.Information(id: "Id1",
                                                version: "Verion1",
                                                name: "Name2",
                                                coordinates: (100, 200))
        XCTAssertNotEqual(info1, info2)
    }
    
    func test_activeExtension_information_inequalityDueToMissingCoordinates() {
        let info1 = ActiveExtension.Information(id: "Id1",
                                                version: "Verion1",
                                                name: "Name1",
                                                coordinates: (100, 200))
        let info2 = ActiveExtension.Information(id: "Id1",
                                                version: "Verion1",
                                                name: "Name1",
                                                coordinates: nil)
        XCTAssertNotEqual(info1, info2)
    }
    
    // MARK: - EntitlementGrant
    
    func test_entitlementGrant_decodesFromJSON() throws {
        let urlString = "https://someurl.com/some/path/to/something.json?param1=1\\u0026param2=2\\u0026param3=3"
        
        let data = Data("""
        {
            "url": "\(urlString)"
        }
        """.utf8)
        
        let entitlementGrant = try JSONDecoder().decode(EntitlementGrant.self, from: data)
        
        XCTAssertEqual(entitlementGrant.url,
                       URL(string: "https://someurl.com/some/path/to/something.json?param1=1&param2=2&param3=3"))
    }
    
    func test_givenInvalidURLString_entitlementGrant_throwsErrorWhenDecoding() {
        let urlString = "!@#$%^&*()_+"
        
        let data = Data("""
        {
            "url": "\(urlString)"
        }
        """.utf8)
        
        do {
            _ = try JSONDecoder().decode(EntitlementGrant.self, from: data)
            XCTFail("Expected to throw decoding error")
        } catch is DecodingError {
        } catch {
            XCTFail("Expected to get \(DecodingError.self), got: \(error)")
        }
    }
    
    // MARK: - Template URLs
    
    func test_imageTemplateURL_decodesFromJSON() throws {
        let data = Data("""
        [
            "https://someurl.com/image-{width}x{height}.png"
        ]
        """.utf8)
        
        let templateURL = try JSONDecoder().decode([TemplateURL<ImageTemplateURLStrategy>].self, from: data).first
        
        XCTAssertEqual(templateURL?.template, "https://someurl.com/image-{width}x{height}.png")
    }
    
    func test_streamKeyTemplateURL_decodesFromJSON() throws {
        let data = Data("""
        [
            "https://someurl.com/{stream_key}"
        ]
        """.utf8)
        
        let templateURL = try JSONDecoder().decode([TemplateURL<StreamKeyTemplateURLStrategy>].self, from: data).first
        
        XCTAssertEqual(templateURL?.template, "https://someurl.com/{stream_key}")
    }
    
    func test_imageTemplateURL_generatesCorrectURL() throws {
        let templateURL = TemplateURL<ImageTemplateURLStrategy>(template: "https://someurl.com/image-{width}x{height}.png")
        
        let url = templateURL.with(width: 100, height: 200)
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url, URL(string: "https://someurl.com/image-100x200.png"))
    }
    
    func test_streamKeyTemplateURL_generatesCorrectURL() throws {
        let templateURL = TemplateURL<StreamKeyTemplateURLStrategy>(template: "https://someurl.com/{stream_key}")
        
        var url = templateURL.with(streamKey: "SomeStreamKey")
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url, URL(string: "https://someurl.com/SomeStreamKey"))
        
        url = templateURL.with(streamKey: StreamKey(streamKey: "SomeStreamKey2"))
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url, URL(string: "https://someurl.com/SomeStreamKey2"))
    }
}
