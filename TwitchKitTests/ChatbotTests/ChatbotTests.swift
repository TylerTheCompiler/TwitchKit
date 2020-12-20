//
//  ChatbotTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/18/20.
//

import Network
import XCTest
@testable import TwitchKit

class MockConnection: ConnectionProtocol {
    static var startHandler: ((_ connection: MockConnection, _ queue: DispatchQueue) -> Void)?
    static var cancelHandler: ((_ connection: MockConnection) -> Void)?
    
    static var sendHandler: (
        (_ connection: MockConnection,
         _ content: Data?,
         _ contentContext: NWConnection.ContentContext,
         _ isComplete: Bool,
         _ completion: NWConnection.SendCompletion) -> Void
    )?
    
    static var receiveHandler: (
        (_ connection: MockConnection,
         _ minimumIncompleteLength: Int,
         _ maximumLength: Int,
         _ completion: @escaping (Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void) -> Void
    )?
    
    static func reset() {
        startHandler = nil
        cancelHandler = nil
        sendHandler = nil
        receiveHandler = nil
    }
    
    var endpoint: NWEndpoint
    var parameters: NWParameters
    
    var stateUpdateHandler: ((_ state: NWConnection.State) -> Void)?
    
    required init(to endpoint: NWEndpoint, using parameters: NWParameters) {
        self.endpoint = endpoint
        self.parameters = parameters
    }
    
    func start(queue: DispatchQueue) {
        Self.startHandler?(self, queue)
    }
    
    func cancel() {
        Self.cancelHandler?(self)
    }
    
    func send(content: Data?,
              contentContext: NWConnection.ContentContext,
              isComplete: Bool,
              completion: NWConnection.SendCompletion) {
        Self.sendHandler?(self, content, contentContext, isComplete, completion)
    }
    
    func receive(minimumIncompleteLength: Int,
                 maximumLength: Int,
                 completion: @escaping (Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void) {
        Self.receiveHandler?(self, minimumIncompleteLength, maximumLength, completion)
    }
}

class ChatbotTests: XCTestCase, ChatbotDelegate {
    let clientId = "MockClientId"
    let clientSecre = "MockClientSecret"
    let redirectURL = URL(string: "mockscheme://mockhost")!
    let chatbotUsername = "TestBot"
    let userId = "MockUserId"
    let userLogin = "MockUserLogin"
    let scopes = Set<Scope>.all
    
    var accessToken: ValidatedUserAccessToken!
    var mockAccessTokenStore: MockAuthTokenStore<ValidatedUserAccessToken>!
    var mockRefreshTokenStore: MockAuthTokenStore<RefreshToken>!
    var authSession: ServerUserAuthSession!
    var chatbot: Chatbot!
    var chatbotDelegateQueue: DispatchQueue!
    
    func configureChatbot(withURLProtocolType urlProtocolType: URLProtocol.Type) {
        accessToken = .init(
            stringValue: "MockAccessToken",
            validation: .init(
                userId: userId,
                login: userLogin,
                clientId: clientId,
                scopes: scopes,
                date: Date()
            )
        )
        
        mockAccessTokenStore = .init()
        mockAccessTokenStore.tokens[userId] = accessToken
        
        mockRefreshTokenStore = .init()
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [urlProtocolType]
        authSession = .init(
            clientId: clientId,
            clientSecret: "MockServerId",
            redirectURL: redirectURL,
            scopes: scopes,
            accessTokenStore: mockAccessTokenStore,
            refreshTokenStore: mockRefreshTokenStore,
            userId: userId,
            urlSessionConfiguration: config
        )
        
        chatbot = .init(
            username: chatbotUsername,
            authSession: .server(authSession),
            delegate: self,
            delegateQueue: chatbotDelegateQueue
        )
        
        chatbot.connectionType = MockConnection.self
    }
    
    override func setUp() {
        chatbotDelegateQueue = .init(label: "ChatbotTestsDelegateQueue")
    }
    
    override func tearDown() {
        MockConnection.reset()
        chatbot = nil
        authSession = nil
        mockRefreshTokenStore = nil
        mockAccessTokenStore = nil
        chatbotDelegateQueue = nil
    }
    
    func test_connect_startsConnection_andCallsRead_andSendsCapabilityRequests_andSendsPassAndNickCommands() {
        let start = expectation(description: "Expected start to be called")
        
        let sends = [
            expectation(description: "Expected first send"),
            expectation(description: "Expected second send"),
            expectation(description: "Expected third send"),
            expectation(description: "Expected fourth send"),
            expectation(description: "Expected fifth send")
        ]
        
        let receives = [
            expectation(description: "Expected first receive"),
            expectation(description: "Expected second receive"),
            expectation(description: "Expected third receive"),
            expectation(description: "Expected fourth receive"),
            expectation(description: "Expected fifth receive"),
            expectation(description: "Expected sixth receive")
        ]
        
        let connectCompletion = expectation(description: "Expected connect completion to be called")
        
        enum RequestHandler: ResponseProviding {
            static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?))?
        }
        
        configureChatbot(withURLProtocolType: MockURLProtocol<RequestHandler>.self)
        
        MockConnection.startHandler = { [weak self] connection, queue in
            XCTAssertNotNil(queue)
            XCTAssertEqual(queue, self?.chatbot.connectionQueue)
            XCTAssertNotNil(connection.stateUpdateHandler)
            connection.stateUpdateHandler?(.ready)
            start.fulfill()
        }
        
        var receiveCount = 0
        MockConnection.receiveHandler = { connection, minIncompleteLength, maxLength, completionHandler in
            defer { receiveCount += 1 }
            XCTAssertEqual(minIncompleteLength, 1)
            XCTAssertEqual(maxLength, 1<<16)
            guard receiveCount <= 6 else {
                XCTFail("Did not expect to get more than 6 receives")
                return
            }
            
            receives[receiveCount].fulfill()
        }
        
        var sendCount = 0
        MockConnection.sendHandler = { [weak self] connection, content, contentContext, isComplete, completion in
            guard let self = self else { return }
            defer { sendCount += 1 }
            switch sendCount {
            case 0: XCTAssertEqual(content, Data("CAP REQ :twitch.tv/membership\r\n".utf8))
            case 1: XCTAssertEqual(content, Data("CAP REQ :twitch.tv/tags\r\n".utf8))
            case 2: XCTAssertEqual(content, Data("CAP REQ :twitch.tv/commands\r\n".utf8))
            case 3: XCTAssertEqual(content, Data("PASS oauth:\(self.accessToken.stringValue)\r\n".utf8))
            case 4: XCTAssertEqual(content, Data("NICK \(self.chatbotUsername.lowercased())\r\n".utf8))
            default:
                XCTFail("Did not expect more than 5 sends")
                return
            }
            
            sends[sendCount].fulfill()
        }
        
        chatbot.connect { response in
            XCTAssertNil(response.error)
            connectCompletion.fulfill()
        }
        
        wait(for: [
            start,
            receives[0], sends[0],
            receives[1], sends[1],
            receives[2], sends[2],
            receives[3], sends[3],
            receives[4], sends[4],
            receives[5],
            connectCompletion
        ], timeout: 1.0, enforceOrder: true)
    }
}
