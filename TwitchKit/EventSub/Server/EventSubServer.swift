//
//  EventSubServer.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/23/20.
//

import Network

extension EventSub {
    
    /// <#Description#>
    open class Server {
        
        /// <#Description#>
        public enum Error: Swift.Error {
            
            /// <#Description#>
            case invalidPort(UInt16)
        }
        
        /// <#Description#>
        public enum State {

            /// Prior to start, the listener will be in the setup state
            case setup

            /// Waiting listeners do not have a viable network
            case waiting(Swift.Error)

            /// Ready listeners are able to receive incoming connections
            /// Bonjour service may not yet be registered
            case ready

            /// Failed listeners are no longer able to receive incoming connections
            case failed(Swift.Error)

            /// Cancelled listeners have been invalidated by the client and will send no more events
            case cancelled
        }
        
        /// <#Description#>
        public let authSession: ServerAppAuthSession
        
        /// <#Description#>
        public let port: NWEndpoint.Port
        
        /// <#Description#>
        public let listener: NWListener
        
        /// <#Description#>
        public private(set) var seenMessageIds = Set<String>()
        
        /// <#Description#>
        public var newConnectionHandler: ((ServerConnection) -> Void)?
        
        /// <#Description#>
        ///
        /// - Parameters:
        ///   - authSession: <#authSession description#>
        ///   - port: <#port description#>
        /// - Throws: <#description#>
        public init(authSession: ServerAppAuthSession, port: NWEndpoint.Port) throws {
            self.authSession = authSession
            self.port = port
            listener = try NWListener(using: .tcp, on: port)
        }
        
        /// <#Description#>
        ///
        /// - Parameters:
        ///   - authSession: <#authSession description#>
        ///   - portNumber: <#portNumber description#>
        /// - Throws: <#description#>
        public convenience init(authSession: ServerAppAuthSession, portNumber: UInt16) throws {
            guard let port = NWEndpoint.Port(rawValue: portNumber) else {
                throw Error.invalidPort(portNumber)
            }
            
            try self.init(authSession: authSession, port: port)
        }
        
        /// <#Description#>
        ///
        /// - Throws: <#description#>
        open func start() throws {
            listener.stateUpdateHandler = { [weak self] in self?.stateDidChange(to: $0) }
            listener.newConnectionHandler = { [weak self] in self?.didAccept(nwConnection: $0) }
            listener.start(queue: .main)
        }
        
        /// <#Description#>
        ///
        /// - Parameter newState: <#newState description#>
        open func stateDidChange(to newState: NWListener.State) {
            switch newState {
            case .ready:
                print("Server ready.")
                
            case .failed(let error):
                print("Server failure, error: \(error.localizedDescription)")
                
            default:
                break
            }
        }
        
        // MARK: - Private
        
        private var connectionsByID: [Int: ServerConnection] = [:]
        
        private func didAccept(nwConnection: NWConnection) {
            let connection = ServerConnection(connection: nwConnection)
            self.connectionsByID[connection.id] = connection
            connection.didStopCallback = { [weak self] _ in
                self?.connectionDidStop(connection)
            }
            
            connection.receiveHandler = { [weak self] connection, message in
                defer { connection.stop() }
                guard let self = self else { return }
                
                do {
                    let eventSubMessage = try EventSub.Message(
                        rawHTTPPostMessageString: message,
                        secret: self.authSession.clientSecret,
                        maxMessageAgeInMinutes: 10,
                        isDuplicateHandler: { !self.seenMessageIds.insert($0).inserted }
                    )
                    
                    switch eventSubMessage {
                    case .webhookCallbackVerification(let verification):
                        let challenge = verification.challenge
                        var response = ["HTTP/1.1 200 OK"]
                        response.append("Content-Length: \(challenge.count)")
                        response.append("Connection: Closed")
                        response.append("Content-Type: text/plain")
                        response.append("")
                        response.append(challenge)
                        connection.send(data: Data(response.joined(separator: "\r\n").utf8))
                    
                    case .notification(let notification):
                        print("Received EventSub notification:", notification)
                        
                        let content = "No content"
                        var response = ["HTTP/1.1 204 No content"]
                        response.append("Content-Length: \(content.count)")
                        response.append("Connection: Closed")
                        response.append("Content-Type: text/plain")
                        response.append("")
                        response.append(content)
                        connection.send(data: Data(response.joined(separator: "\r\n").utf8))
                    }
                } catch EventSub.Message.Error.invalidSignature {
                    print("Received invalid EventSub message signature")
                    
                    let content = "Forbidden"
                    var response = ["HTTP/1.1 403 Forbidden"]
                    response.append("Content-Length: \(content.count)")
                    response.append("Connection: Closed")
                    response.append("Content-Type: text/plain")
                    response.append("")
                    response.append(content)
                    connection.send(data: Data(response.joined(separator: "\r\n").utf8))
                } catch EventSub.Message.Error.invalidTimestamp {
                    print("Received EventSub message that was too old (invalid timestamp)")
                } catch EventSub.Message.Error.duplicateMessageId(let duplicateMessageId) {
                    print("Received duplicate EventSub message ID:", duplicateMessageId)
                } catch {
                    print("EventSub message parse error:", error)
                }
            }
            
            newConnectionHandler?(connection)
            
            connection.start()
            print("server did open connection \(connection.id)")
        }
        
        private func connectionDidStop(_ connection: ServerConnection) {
            connectionsByID.removeValue(forKey: connection.id)
            print("server did close connection \(connection.id)")
        }
        
        private func stop() {
            listener.stateUpdateHandler = nil
            listener.newConnectionHandler = nil
            listener.cancel()
            
            for connection in connectionsByID.values {
                connection.didStopCallback = nil
                connection.stop()
            }
            
            connectionsByID.removeAll()
        }
    }
}
