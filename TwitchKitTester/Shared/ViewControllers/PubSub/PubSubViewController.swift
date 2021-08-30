//
//  PubSubViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

class PubSubViewController: PlatformIndependentViewController {
    var authSession: ServerUserAuthSession? {
        didSet { if isViewLoaded { updatePubSubConnection() } }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePubSubConnection()
    }
    
    private func updatePubSubConnection() {
        if let authSession = authSession {
            authSession.getAccessToken { result in
                switch result {
                case .success((let accessToken, _)):
                    let pubSub = PubSub.Connection(authSession: authSession)
                    self.pubSubConnection = pubSub
                    pubSub.delegate = self
                    pubSub.connect()
                    pubSub.listen(to: [.userModerationNotifications(
                        userId: accessToken.validation.userId,
                        channelId: "29999098"
                    )])
                    
                case .failure:
                    break
                }
            }
        } else {
            pubSubConnection?.disconnect()
            pubSubConnection = nil
        }
    }
    
    private var pubSubConnection: PubSub.Connection?
}

extension PubSubViewController: PubSubConnectionDelegate {
    func pubSubConnection(_ connection: PubSub.Connection, didReceive message: PubSub.Message) {
        print("PubSub message:", message)
    }
    
    func pubSubConnection(_ connection: PubSub.Connection, didFailToSendDataWith error: Error) {
        print("Send error:", error)
    }
    
    func pubSubConnection(_ connection: PubSub.Connection, didFailToReceiveDataWith error: Error) {
        print("Receive error:", error)
    }
}
