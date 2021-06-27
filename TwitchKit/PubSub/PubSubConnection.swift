//
//  PubSubConnection.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/21/20.
//

/// An empty type that is used for containing all PubSub-related types, like
/// `PubSub.Topic` `PubSub.Connection`, and `PubSub.Message`.
public enum PubSub {
    
    /// Represents a connection to Twitch's PubSub service.
    ///
    /// Use this to listen and respond to PubSub topics.
    open class Connection {
        
        /// An error related to PubSub connections.
        public enum Error: Swift.Error {
            
            /// Thrown when you try to send something through a PubSub connection that has not connected to Twitch yet.
            case notConnected
            
            /// Thrown when sending data that cannot be encoded properly or when receiving data that cannot be
            /// decoded properly.
            case invalidData(Data)
            
            /// Thrown when receiving an unknown response type.
            case unknownResponseType
            
            /// Thrown when attemping to listen to a topic and a response returns with an error message.
            /// The string parameter is the error message.
            case listenError(String)
            
            /// Thrown when decoding a received PubSub message of an unknown type.
            case unknownMessageType(String)
        }
        
        /// The session to use for authorization.
        public let authSession: ServerUserAuthSession
        
        /// An object that is notified of PubSub events.
        open weak var delegate: PubSubConnectionDelegate?
        
        /// The dispatch queue on which all delegate callbacks are called. If nil,
        /// delegate callbacks are called on whatever the current queue is.
        open var delegateQueue: DispatchQueue?
        
        /// The topics that this connection is currently listening to.
        @ReaderWriterValue(Connection.self, propertyName: "currentTopics")
        public private(set) var currentTopics = Set<Topic>()
        
        /// Whether the connection should automatically try to reconnect to Twitch after receiving a RECONNECT message.
        /// Default: true.
        @ReaderWriterValue(Connection.self, propertyName: "shouldHandleRedirectsAutomatically")
        public var shouldHandleRedirectsAutomatically = true
        
        /// Whether the chatbot is currently attempting to reconnect to Twitch.
        public var isAttemptingReconnect: Bool {
            reconnectIteration != nil
        }
        
        /// Creates a new PubSub connection object.
        ///
        /// To listen to events, assign an object to the connection's `delegate` and conform that object's type to
        /// `PubSubConnectionDelegate`.
        ///
        /// - Parameters:
        ///   - authSession: The session to use for authorization.
        ///   - delegate: An object that is notified of PubSub events. You can change this after initialization.
        ///               Default: nil.
        ///   - delegateQueue: The dispatch queue on which all delegate callbacks are called. If nil, delegate
        ///                    callbacks are called on whatever the current queue is. Default: the main queue.
        ///   - urlSessionConfiguration: The configuration to use for the internal URL session. Default: the default
        ///                              URL session configuration.
        public init(authSession: ServerUserAuthSession,
                    delegate: PubSubConnectionDelegate? = nil,
                    delegateQueue: DispatchQueue? = .main,
                    urlSessionConfiguration: URLSessionConfiguration? = nil) {
            self.authSession = authSession
            self.delegate = delegate
            self.delegateQueue = delegateQueue
            let webSocketDelegate = WebSocketDelegate()
            self.urlSession = .init(configuration: urlSessionConfiguration ?? authSession.urlSession.configuration,
                                    delegate: webSocketDelegate,
                                    delegateQueue: .main)
            
            self.webSocketDelegate = webSocketDelegate
            
            webSocketDelegate.taskDidOpen = { [weak self] _, _ in
                guard let self = self,
                      self.isAttemptingReconnect, let reconnectIteration = self.reconnectIteration else {
                    return
                }
                
                self.listen(to: Array(self.topicsToListenToOnReconnect)) { error in
                    if error != nil {
                        self.disconnect()
                        self.attemptReconnect(withIteration: reconnectIteration + 1)
                    } else {
                        self.topicsToListenToOnReconnect = []
                        self.reconnectIteration = nil
                    }
                }
            }
            
            webSocketDelegate.taskDidClose = { [weak self] _, _, _ in
                self?.disconnect()
            }
        }
        
        deinit {
            disconnect()
        }
        
        /// Connects to Twitch's PubSub service.
        open func connect() {
            disconnect()
            // swiftlint:disable:next force_unwrapping
            task = urlSession.webSocketTask(with: URL(string: "wss://pubsub-edge.twitch.tv")!)
            task?.resume()
            startPingTimer()
            read()
        }
        
        /// Disconnects from Twitch's PubSub service.
        open func disconnect() {
            currentTopics = []
            stopPingTimer()
            task?.cancel(with: .normalClosure, reason: nil)
            task = nil
        }
        
        /// Starts listening to the given PubSub topics. If the connection is not yet connected to Twitch,
        /// then `connect` is called first.
        ///
        /// - Parameters:
        ///   - topics: The PubSub topics to listen to.
        ///   - completion: A closure called when the listen request finishes. The closure's parameter is the error
        ///                 that occurred when requesting to listen to the topics, or nil if no error occurred.
        ///                 Default: nil.
        public func listen(to topics: [Topic], completion: ((_ error: Swift.Error?) -> Void)? = nil) {
            if task == nil {
                connect()
            }
            
            guard !topics.isEmpty else {
                completion?(nil)
                return
            }
            
            authSession.getAccessToken { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success((let accessToken, _)):
                    let listenMessage = ListenMessage(type: .listen, topics: topics, accessToken: accessToken)
                    let nonce = listenMessage.nonce
                    self.listenCompletionHandlers[nonce] = completion
                    self.send(listenMessage) { [weak self] error in
                        if error != nil {
                            self?.listenCompletionHandlers[nonce] = nil
                        } else {
                            self?.currentTopics.formUnion(topics)
                        }
                        
                        completion?(error)
                    }
                    
                case .failure(let error):
                    completion?(error)
                }
            }
        }
        
        /// Stops listening to the given PubSub topics.
        ///
        /// - Parameters:
        ///   - topics: The topics to unlisten to.
        ///   - completion: A closure called when the unlisten request finishes. The closure's parameter is the error
        ///                 that occurred when requesting to unlisten to the topics, or nil if no error occurred.
        ///                 Default: nil.
        public func unlisten(to topics: [Topic], completion: ((Swift.Error?) -> Void)? = nil) {
            guard !topics.isEmpty else {
                completion?(nil)
                return
            }
            
            authSession.getAccessToken { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success((let accessToken, _)):
                    let unlistenMessage = ListenMessage(type: .unlisten, topics: topics, accessToken: accessToken)
                    let nonce = unlistenMessage.nonce
                    self.listenCompletionHandlers[nonce] = completion
                    self.send(unlistenMessage) { [weak self] error in
                        if error != nil {
                            self?.listenCompletionHandlers[nonce] = nil
                        } else {
                            self?.currentTopics.subtract(topics)
                        }
                        
                        completion?(error)
                    }
                case .failure(let error):
                    completion?(error)
                }
            }
        }
        
        private func send<T>(_ encodable: T, completion: ((Swift.Error?) -> Void)?) where T: Encodable {
            guard let task = task, task.state == .running else {
                let error = Error.notConnected
                completion?(error)
                tryExecutingOnDelegateQueue {
                    self.delegate?.pubSubConnection(self, didFailToSendDataWith: error)
                }
                
                return
            }
            
            do {
                let data = try JSONEncoder.camelCaseToSnakeCase.encode(encodable)
                guard let string = String(data: data, encoding: .utf8) else { throw Error.invalidData(data) }
                
                task.send(.string(string)) { [weak self] error in
                    completion?(error)
                    guard let self = self else { return }
                    if let error = error {
                        self.tryExecutingOnDelegateQueue {
                            self.delegate?.pubSubConnection(self, didFailToSendDataWith: error)
                        }
                    } else {
                        self.tryExecutingOnDelegateQueue {
                            self.delegate?.pubSubConnection(self, didSend: string)
                        }
                    }
                }
                
                read()
            } catch {
                completion?(error)
                tryExecutingOnDelegateQueue {
                    self.delegate?.pubSubConnection(self, didFailToSendDataWith: error)
                }
            }
        }
        
        private func read() {
            task?.receive { [weak self] result in
                guard let self = self else { return }
                defer { self.read() }
                
                switch result {
                case .success(.string(let string)):
                    let jsonData = Data(string.utf8)
                    do {
                        guard let dictionary = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                              let type = dictionary["type"] as? String else {
                            throw Error.invalidData(jsonData)
                        }
                        
                        switch type {
                        case "RESPONSE":
                            guard let nonce = dictionary["nonce"] as? String,
                                  let handler = self.listenCompletionHandlers[nonce] else {
                                return
                            }
                            
                            let error = dictionary["error"] as? String ?? ""
                            if error.isEmpty {
                                handler(nil)
                            } else {
                                handler(Error.listenError(error))
                            }
                            
                            self.listenCompletionHandlers[nonce] = nil
                            
                        case "PONG":
                            break
                            
                        case "RECONNECT":
                            self.tryExecutingOnDelegateQueue {
                                self.delegate?.pubSubConnection(self, didReceive: .reconnect)
                            }
                            
                            if self.shouldHandleRedirectsAutomatically {
                                self.attemptReconnect()
                            }
                            
                        case "MESSAGE":
                            guard let data = dictionary["data"] as? [String: Any],
                                  let topicString = data["topic"] as? String,
                                  let topic = Topic(rawValue: topicString),
                                  let messageString = (data["message"] ?? data["data"]) as? String else {
                                throw Error.invalidData(jsonData)
                            }
                            
                            let messageData = Data(messageString.utf8)
                            
                            let decoder = JSONDecoder.snakeCaseToCamelCase
                            decoder.userInfo = [.init("topic"): topic]
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            
                            let message = try decoder.decode(Message.self, from: messageData)
                            
                            self.tryExecutingOnDelegateQueue {
                                self.delegate?.pubSubConnection(self, didReceive: message)
                            }
                            
                        default:
                            throw Error.unknownMessageType(type)
                        }
                    } catch {
                        self.tryExecutingOnDelegateQueue {
                            self.delegate?.pubSubConnection(self, didFailToReceiveDataWith: error)
                        }
                    }
                    
                case .success(.data(let data)):
                    self.tryExecutingOnDelegateQueue {
                        self.delegate?.pubSubConnection(self, didReceive: data)
                    }
                    
                case .failure(let error):
                    self.tryExecutingOnDelegateQueue {
                        self.delegate?.pubSubConnection(self, didFailToReceiveDataWith: error)
                    }
                    
                @unknown default:
                    self.tryExecutingOnDelegateQueue {
                        self.delegate?.pubSubConnection(self, didFailToReceiveDataWith: Error.unknownResponseType)
                    }
                }
            }
        }
        
        private func startPingTimer() {
            stopPingTimer()
            let nextFireTime = Date() + (4.0 * 60.0) + .random(in: 0.0..<30.0)
            let pingTimer = Timer(fire: nextFireTime, interval: 0, repeats: false) { [weak self] _ in
                self?.sendPing()
                self?.startPingTimer()
            }
            
            self.pingTimer = pingTimer
            
            DispatchQueue.global(qos: .utility).async {
                RunLoop.current.add(pingTimer, forMode: .common)
                RunLoop.current.run()
            }
        }
        
        private func stopPingTimer() {
            pingTimer?.invalidate()
            pingTimer = nil
        }
        
        private func sendPing() {
            print("Sending PING")
            send(PingMessage()) { error in
                if let error = error {
                    print("Ping error:", error)
                }
            }
        }
        
        private func tryExecutingOnDelegateQueue(_ closure: @escaping () -> Void) {
            if let delegateQueue = delegateQueue {
                delegateQueue.async(execute: closure)
            } else {
                closure()
            }
        }
        
        private func attemptReconnect(withIteration iteration: Int = -1) {
            guard shouldHandleRedirectsAutomatically else {
                reconnectIteration = nil
                topicsToListenToOnReconnect = []
                return
            }
            
            reconnectIteration = iteration
            
            if iteration == -1 {
                topicsToListenToOnReconnect = currentTopics
                disconnect()
            }
            
            let delay = Double(max(Int(pow(2, Double(iteration - 1))), 0))
            print("Attempting reconnect after \(Int(delay)) seconds...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.connect()
            }
        }
        
        private let urlSession: URLSession
        private var task: URLSessionWebSocketTask?
        private var pingTimer: Timer?
        private let webSocketDelegate: WebSocketDelegate // swiftlint:disable:this weak_delegate
        
        @ReaderWriterValue(Connection.self, propertyName: "listenCompletionHandlers")
        private var listenCompletionHandlers = [String: (Swift.Error?) -> Void]()
        
        @ReaderWriterValue(wrappedValue: nil, Connection.self, propertyName: "reconnectIteration")
        private var reconnectIteration: Int?
        
        @ReaderWriterValue(Connection.self, propertyName: "topicsToListenToOnReconnect")
        private var topicsToListenToOnReconnect = Set<Topic>()
    }
    
    private struct ListenMessage: Encodable {
        enum ListenType: String, Encodable {
            case listen = "LISTEN"
            case unlisten = "UNLISTEN"
        }
        
        struct Data: Encodable {
            let topics: [Topic]
            let authToken: String
        }
        
        let type: ListenType
        let nonce = UUID().uuidString
        let data: Data
        
        init(type: ListenType, topics: [Topic], accessToken: ValidatedUserAccessToken) {
            self.type = type
            data = .init(topics: topics, authToken: accessToken.stringValue)
        }
    }
    
    private struct PingMessage: Encodable {
        let type = "PING"
    }
}

extension PubSub.Connection {
    fileprivate class WebSocketDelegate: NSObject {
        var taskDidOpen: ((_ task: URLSessionWebSocketTask,
                           _ protocol: String?) -> Void)?
        
        var taskDidClose: ((_ task: URLSessionWebSocketTask,
                            _ closeCode: URLSessionWebSocketTask.CloseCode,
                            _ reason: Data?) -> Void)?
    }
}

extension PubSub.Connection.WebSocketDelegate: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession,
                           webSocketTask: URLSessionWebSocketTask,
                           didOpenWithProtocol protocol: String?) {
        taskDidOpen?(webSocketTask, `protocol`)
    }
    
    public func urlSession(_ session: URLSession,
                           webSocketTask: URLSessionWebSocketTask,
                           didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                           reason: Data?) {
        taskDidClose?(webSocketTask, closeCode, reason)
    }
}
