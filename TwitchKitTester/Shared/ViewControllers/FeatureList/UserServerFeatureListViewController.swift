//
//  UserServerFeatureListViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

class UserServerFeatureListViewController: FeatureListViewController {
    var authSettings: UserServerAuthSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        features = [
            .embedding,
            .deepLinks,
            .auth,
            .endpoints,
            .chatbot,
            .pubSub
        ]
        
        if let userId = authSettings?.authSession.userId {
            title = "User Server API Session (\(userId))"
        } else {
            title = "User Server API Session"
        }
    }
    
    override func showAuth(in viewController: PlatformIndependentViewController) {
        guard let viewController = viewController as? UserServerAuthViewController else { return }
        viewController.settings = authSettings
    }
    
    override func showEndpoints(in viewController: PlatformIndependentViewController) {
        guard let viewController = viewController as? UserServerEndpointListViewController else { return }
        viewController.authSession = authSettings?.authSession
    }
    
    override func showChatbot(in viewController: ChatbotViewController) {
        viewController.authSession = authSettings?.authSession
    }
    
    override func showPubSub(in viewController: PubSubViewController) {
        viewController.authSession = authSettings?.authSession
    }
}
