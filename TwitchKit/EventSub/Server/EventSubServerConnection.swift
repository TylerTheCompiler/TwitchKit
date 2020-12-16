//
//  EventSubServerConnection.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/23/20.
//

import Network

extension EventSub {
    
    /// <#Description#>
    public class ServerConnection {
        
        /// <#Description#>
        public let connection: NWConnection
        
        /// <#Description#>
        public let id: Int
        
        /// <#Description#>
        public var receiveHandler: ((ServerConnection, String) -> Void)?
        
        /// <#Description#>
        public var didStopCallback: ((Error?) -> Void)?
        
        /// <#Description#>
        ///
        /// - Parameter connection: <#connection description#>
        public init(connection: NWConnection) {
            self.connection = connection
            id = ServerConnection.nextID
            ServerConnection.nextID += 1
        }
        
        /// <#Description#>
        public func start() {
            print("connection \(id) will start")
            connection.stateUpdateHandler = self.stateDidChange(to:)
            setupReceive()
            connection.start(queue: .main)
        }
        
        /// <#Description#>
        ///
        /// - Parameter data: <#data description#>
        public func send(data: Data) {
            self.connection.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    self.connectionDidFail(error: error)
                    return
                }
                
                if let string = String(data: data, encoding: .utf8) {
                    print("connection \(self.id) did send: \(string)")
                }
            })
        }
        
        /// <#Description#>
        public func stop() {
            print("connection \(id) will stop")
        }
        
        // MARK: - Private
        
        private static var nextID = 0
        
        private func stateDidChange(to state: NWConnection.State) {
            switch state {
            case .waiting(let error):
                connectionDidFail(error: error)
                
            case .ready:
                print("connection \(id) ready")
                
            case .failed(let error):
                connectionDidFail(error: error)
                
            default:
                break
            }
        }
        
        private func setupReceive() {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 1<<16) { (data, _, isComplete, error) in
                if let data = data, !data.isEmpty,
                   let message = String(data: data, encoding: .utf8) {
                    self.receiveHandler?(self, message)
                }
                
                if isComplete {
                    self.connectionDidEnd()
                } else if let error = error {
                    self.connectionDidFail(error: error)
                } else {
                    self.setupReceive()
                }
            }
        }
        
        private func connectionDidFail(error: Error) {
            print("connection \(id) did fail, error: \(error)")
            stop(error: error)
        }
        
        private func connectionDidEnd() {
            print("connection \(id) did end")
            stop(error: nil)
        }
        
        private func stop(error: Error?) {
            connection.stateUpdateHandler = nil
            connection.cancel()
            if let didStopCallback = didStopCallback {
                self.didStopCallback = nil
                didStopCallback(error)
            }
        }
    }
}
